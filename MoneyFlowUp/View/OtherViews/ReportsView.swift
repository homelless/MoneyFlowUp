import SwiftUI
import Charts

// Экран "Отчеты": показывает KPI, график доход/расход по времени и круговую диаграмму расходов
struct ReportsView: View {
    
    @Bindable var transactionVM: TransactionVM   // Источник транзакций из вашего проекта (наблюдаемый через Observation)
    @State private var vm = ReportsViewModel() // Локальная ViewModel с агрегациями (живет в этом вью)
    
    // Локализованный стиль валюты для форматирования чисел (???)
    private var currency: FloatingPointFormatStyle<Double>.Currency {
        .currency(code: "$")
    }
    
    var body: some View {
        ZStack {
            Color("фон").ignoresSafeArea() // Фон из вашего набора цветов на весь экран
            
            ScrollView { // Прокручиваемый контейнер для контента
                VStack(spacing: 16) { // Вертикальная колонка элементов с отступом между блоками
                    headerControls // Блок с выбором периода (диапазон дат) и фильтра потоков
                    
                    kpiView        // Блок KPI (доход/расход/баланс)
                    
                    expenseDonut   // Круговая диаграмма расходов по категориям
                        .animation(.easeInOut, value: vm.donutSlices) // Анимировать изменения сегментов
                }
                .padding(.horizontal)   // Горизонтальные отступы
                .padding(.vertical, 12) // Вертикальные отступы
            }
        }
        // Перестроение данных при появлении экрана
        .onAppear { vm.rebuild(from: transactionVM.transactions) }
        // Перестроение при изменении списка транзакций: отслеживаем количество, чтобы не требовать Equatable массива моделей
        .onChange(of: transactionVM.transactions.count) { _, _ in
            vm.rebuild(from: transactionVM.transactions)
        }
        // Перестроение при смене диапазона дат
        .onChange(of: vm.fromDate) { _, _ in
            vm.rebuild(from: transactionVM.transactions)
        }
        .onChange(of: vm.toDate) { _, _ in
            vm.rebuild(from: transactionVM.transactions)
        }
        // Перестроение при смене фильтра потоков (если в будущем будет влиять на агрегации)
        .onChange(of: vm.flowFilter) { _, _ in
            vm.rebuild(from: transactionVM.transactions)
        }
    }
    
    //Переключатели периода и потоков
    
    private var headerControls: some View {
        VStack(spacing: 8) { // Контейнер для двух рядов контролов
            // Ряд 1: Диапазон дат
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Период")
                        .font(.headline)
                        .foregroundStyle(.текст)
                          Spacer()
             
                    DatePicker("С", selection: Binding(get: { vm.fromDate }, set: { vm.fromDate = $0 }), displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .environment(\.locale, Locale(identifier: "ru_RU"))
                    Text("—")
                    DatePicker("По", selection: Binding(get: { vm.toDate }, set: { vm.toDate = $0 }), displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .environment(\.locale, Locale(identifier: "ru_RU"))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Ряд 2: Фильтр потоков
            HStack {
                Text("Категория")     // Подпись
                    .font(.headline)
                    .foregroundStyle(.текст)
                Spacer()
                Picker("", selection: $vm.flowFilter) { // Сегментированный фильтр: Доход/Расход/Оба
                    ForEach(ReportsViewModel.FlowFilter.allCases) { f in
                        Text(f.rawValue).tag(f)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 320)
            }
        }
    }
    
    //Карточки с суммами
    
    private var kpiView: some View {
        HStack(spacing: 12) { // Три карточки в ряд
            kpiCard(title: "Доход", value: vm.totalIncome, color: .green)            // Доход (зелёный)
            kpiCard(title: "Расход", value: vm.totalExpense, color: .red)            // Расход (красный)
            kpiCard(title: "Итог ", value: vm.net, color: vm.net >= 0 ? .green : .red) // Итог (цвет по знаку)
        }
    }
    
    // Отдельная карточка KPI
    private func kpiCard(title: String, value: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.текст)
            Text(value, format: .currency(code: "$"))
                .font(.title3.bold())
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color("ячейка"))
        .background(
            RoundedRectangle(cornerRadius: 12),
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.текст, lineWidth: 1)
        )
    }
    
    //Круговая диаграмма
    
    private var expenseDonut: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(titleForDonut) // Заголовок блока
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundStyle(.текст)

            
            if vm.donutSlices.isEmpty { // Если нет сегментов — пустое состояние
                emptyState
            } else {
                Chart { // Круговая диаграмма
                    ForEach(vm.donutSlices) { slice in // Для каждого сегмента
                        SectorMark(
                            angle: .value("Сумма", slice.amount),
                            innerRadius: .ratio(0.55),
                            outerRadius: .ratio(1.0)
                        )
                        .foregroundStyle(slice.color)
                        .annotation(position: .overlay, alignment: .center) {
                            let persent = slice.percent * 100
                            if persent < 5 {
                                Text("")
                            } else {
                                Text("\(Int(round(slice.percent * 100)))%")
                                    .font(.caption.bold())
                                    .foregroundStyle(Color.white.opacity(0.9))
                                    .shadow(radius: 1)
                            }
                        }
                    }
                }
                .padding(.vertical, 12)
                .frame(height: 320)
                .background(Color("ячейка"))
                .background(
                    RoundedRectangle(cornerRadius: 12)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.текст, lineWidth: 1)
                )
                
                // Легенда под диаграммой
                VStack(spacing: 6) {
                    ForEach(vm.donutSlices) { slice in
                        HStack {
                            Circle().fill(slice.color).frame(width: 10, height: 10)
                            Image(systemName: slice.icon)
                            Text(slice.name)
                                .lineLimit(1)
                            Spacer()
                            Text(slice.amount, format: currency)
                                .font(.callout.monospacedDigit())
                            Text("(\(Int(round(slice.percent * 100)))%)")
                                .foregroundColor(.текст)
                                .font(.caption)
                        }
                        .padding(.horizontal, 8)
                    }
                }
                .padding(.vertical, 10)
                .background(Color("ячейка"))
                .background(
                    RoundedRectangle(cornerRadius: 12)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.текст, lineWidth: 1)
                )
            }
        }
    }
    
    private var titleForDonut: String {
        switch vm.flowFilter {
        case .both: return "Соотношение Доход/Расход"
        case .expense: return "Структура расходов по категориям"
        case .income: return "Структура доходов по категориям"
        }
    }
    
    // Заглушка "нет данных" для диаграммы
    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.pie")
                .font(.system(size: 48))
                .foregroundColor(.текст)
            Text("Нет данных за выбранный период")
                .foregroundColor(.текст)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.ячейка).opacity(0.8))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.2), lineWidth: 1)
        )
    }
}

