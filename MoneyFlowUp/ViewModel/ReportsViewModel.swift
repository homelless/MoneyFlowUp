import Foundation
import SwiftUI
import Observation


@Observable
@MainActor
final class ReportsViewModel { 
    
    // Фильтр отображаемых потоков: доход/расход/оба
    enum FlowFilter: String, CaseIterable, Identifiable {
        case both = "Оба"
        case expense = "Расход"
        case income = "Доход"
        
        var id: String { rawValue }
    }
    
    // Точка временного ряда (если захотите добавить график по дням)
    struct TimePoint: Identifiable, Hashable {
        let id: Date
        let date: Date
        let income: Double
        let expense: Double
    }
    
    // Сегмент круговой диаграммы
    struct CategorySlice: Identifiable, Hashable {
        let id: String
        let name: String
        let icon: String
        let color: Color
        let amount: Double
        let percent: Double
    }
    
    // Диапазон дат
    var fromDate: Date
    var toDate: Date
    
    // Фильтр потоков
    var flowFilter: FlowFilter = .both
    
    // Данные для UI
    private(set) var timeSeries: [TimePoint] = []
    private(set) var donutSlices: [CategorySlice] = []
    private(set) var totalIncome: Double = 0
    private(set) var totalExpense: Double = 0
    private(set) var net: Double = 0
    
    // Если понадобится подсветка точки графика
    var selectedDateBin: Date?
    
    private let calendar = Calendar.current
    
    init() {
        // Значения по умолчанию: текущий месяц (с 1 по последний день)
        let now = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        let startOfNextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
        let lastDay = calendar.date(byAdding: .day, value: -1, to: startOfNextMonth)!
        self.fromDate = startOfMonth
        self.toDate = lastDay
    }
    
    // Перестройка агрегатов на основе списка транзакций и выбранного диапазона дат
    func rebuild(from transactions: [Transaction]) {
        // Нормализуем границы: включительно по дате
        let start = calendar.startOfDay(for: fromDate)
        // Правую границу делаем эксклюзивной: следующий день от выбранной "toDate"
        let endExclusive = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: toDate)) ?? toDate
        
        // Фильтруем транзакции по диапазону
        let filtered = transactions.filter { tx in
            tx.date >= start && tx.date < endExclusive
        }
        
        // Разделяем транзакции на расходы и доходы
        let expenses = filtered.filter { $0.category.group == .cost }
        let incomes  = filtered.filter { $0.category.group == .income }
        
        // KPI
        totalExpense = expenses.reduce(0) { $0 + $1.amount }
        totalIncome  = incomes.reduce(0)  { $0 + $1.amount }
        net = totalIncome - totalExpense
        
        // Временной ряд по дням (если добавите график по дням — уже готово)
        let bins = makeDailyBins(start: start, endExclusive: endExclusive)
        timeSeries = bins.map { binStart in
            let binEnd = calendar.date(byAdding: .day, value: 1, to: binStart)!
            let expSum = expenses
                .filter { $0.date >= binStart && $0.date < binEnd }
                .reduce(0) { $0 + $1.amount }
            let incSum = incomes
                .filter { $0.date >= binStart && $0.date < binEnd }
                .reduce(0) { $0 + $1.amount }
            return TimePoint(id: binStart, date: binStart, income: incSum, expense: expSum)
        }
        
        // Круговая диаграмма и легенда в зависимости от фильтра
        switch flowFilter {
        case .both:
            // Два слайса: Доход и Расход (без категорий), но только если суммы > 0
            let incomeAmount = totalIncome
            let expenseAmount = totalExpense
            
            // Если нет ни доходов, ни расходов — показываем пустое состояние
            guard incomeAmount > 0 || expenseAmount > 0 else {
                donutSlices = []
                return
            }
            
            let totalForPercent = max(incomeAmount + expenseAmount, 0.000001)
            var slices: [CategorySlice] = []
            if incomeAmount > 0 {
                slices.append(
                    CategorySlice(
                        id: "both_income",
                        name: "Доход",
                        icon: "arrow.up.circle.fill",
                        color: Color.green.opacity(0.85),
                        amount: incomeAmount,
                        percent: incomeAmount / totalForPercent
                    )
                )
            }
            if expenseAmount > 0 {
                slices.append(
                    CategorySlice(
                        id: "both_expense",
                        name: "Расход",
                        icon: "arrow.down.circle.fill",
                        color: Color.red.opacity(0.85),
                        amount: expenseAmount,
                        percent: expenseAmount / totalForPercent
                    )
                )
            }
            // Сортируем для стабильности легенды
            donutSlices = slices.sorted { $0.amount > $1.amount }
            
        case .expense:
            // Слайсы по категориям расходов
            let expenseTotal = max(totalExpense, 0.000001)
            let grouped = Dictionary(grouping: expenses, by: { $0.category })
            let slicesRaw: [(TransactionCategory, Double)] = grouped.map { (key, arr) in
                (key, arr.reduce(0) { $0 + $1.amount })
            }
            .filter { $0.1 > 0 }
            .sorted(by: { $0.1 > $1.1 })
            
            donutSlices = slicesRaw.map { (cat, sum) in
                let percent = sum / expenseTotal
                let color = colorForStableID(cat.id)
                return CategorySlice(
                    id: cat.id,
                    name: cat.name,
                    icon: cat.icon,
                    color: color,
                    amount: sum,
                    percent: percent
                )
            }
            
        case .income:
            // Слайсы по категориям доходов
            let incomeTotal = max(totalIncome, 0.000001)
            let grouped = Dictionary(grouping: incomes, by: { $0.category })
            let slicesRaw: [(TransactionCategory, Double)] = grouped.map { (key, arr) in
                (key, arr.reduce(0) { $0 + $1.amount })
            }
            .filter { $0.1 > 0 }
            .sorted(by: { $0.1 > $1.1 })
            
            donutSlices = slicesRaw.map { (cat, sum) in
                let percent = sum / incomeTotal
                let color = colorForStableID(cat.id)
                return CategorySlice(
                    id: cat.id,
                    name: cat.name,
                    icon: cat.icon,
                    color: color,
                    amount: sum,
                    percent: percent
                )
            }
        }
    }
    
    
    private func makeDailyBins(start: Date, endExclusive: Date) -> [Date] {
        var bins: [Date] = []
        var cursor = start
        while cursor < endExclusive {
            bins.append(cursor)
            cursor = calendar.date(byAdding: .day, value: 1, to: cursor)!
        }
        return bins
    }
    
    // Детминированный цвет на основе id (стабильная палитра)
    private func colorForStableID(_ id: String) -> Color {
        let hash = abs(id.hashValue)
        let hue = Double((hash % 256)) / 255.0
        let sat = 0.85
        let bri = 0.65
        return Color(hue: hue, saturation: sat, brightness: bri)
    }
}
