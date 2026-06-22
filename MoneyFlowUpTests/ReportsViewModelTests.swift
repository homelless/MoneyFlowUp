import Testing
import Foundation
@testable import MoneyFlowUp

// Тесты агрегации отчётов: KPI (доход/расход/итог), фильтр диапазона дат и сегменты диаграммы.
@MainActor
struct ReportsViewModelTests {

    private let day = Date(timeIntervalSince1970: 1_700_000_000)

    private var cost: CostCategory { CostCategory.all.first! }
    private var income: IncomeCategory { IncomeCategory.all.first! }

    // Аккаунт-заглушка для конструктора Transaction (логика отчётов не обращается к SwiftData).
    private func stubAccount() -> Account {
        Account(id: UUID(), name: "A", balance: 0, currencyRaw: "$", descriptionAccount: "")
    }

    private func tx(_ amount: Double, _ category: TransactionCategory, at date: Date) -> Transaction {
        Transaction(id: UUID(), amount: amount, category: category, date: date, account: stubAccount())
    }

    private func makeVM() -> ReportsViewModel {
        let vm = ReportsViewModel()
        let cal = Calendar.current
        vm.fromDate = cal.startOfDay(for: day)
        vm.toDate = day
        return vm
    }

    @Test func kpiSumsIncomeExpenseAndNet() {
        let vm = makeVM()
        vm.flowFilter = .both
        let txs = [
            tx(100, .income(income), at: day),
            tx(50, .income(income), at: day),
            tx(30, .cost(cost), at: day)
        ]
        vm.rebuild(from: txs)

        #expect(vm.totalIncome == 150)
        #expect(vm.totalExpense == 30)
        #expect(vm.net == 120)
    }

    @Test func bothFilterProducesIncomeAndExpenseSlices() {
        let vm = makeVM()
        vm.flowFilter = .both
        vm.rebuild(from: [
            tx(100, .income(income), at: day),
            tx(40, .cost(cost), at: day)
        ])
        #expect(vm.donutSlices.count == 2)
    }

    @Test func transactionsOutsideRangeAreIgnored() {
        let vm = makeVM()
        vm.flowFilter = .both
        let outside = day.addingTimeInterval(60 * 60 * 24 * 10) // +10 дней, вне диапазона
        vm.rebuild(from: [
            tx(100, .income(income), at: day),
            tx(999, .income(income), at: outside)
        ])
        #expect(vm.totalIncome == 100)
    }

    @Test func emptyRangeGivesNoSlices() {
        let vm = makeVM()
        vm.flowFilter = .both
        vm.rebuild(from: [])
        #expect(vm.donutSlices.isEmpty)
        #expect(vm.net == 0)
    }
}
