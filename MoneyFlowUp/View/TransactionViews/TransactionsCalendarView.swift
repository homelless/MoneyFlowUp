import SwiftUI

// Экран с календарем и списком транзакций за выбранную дату
struct TransactionsCalendarView: View {

    // Путь навигации (NavigationStack)
    @Binding var path: [Route]
    
    // Локальное состояние выбранной даты (по умолчанию — сегодня)
    @State private var selectedDate = Date()
    // Локальное состояние выбранного фильтра по группе транзакций (опционально)
    @State private var selectedFilter: TransactionGroup?

    // Вью-модель транзакций, помечена @Bindable для двусторонней синхронизации с @Observable
    @Bindable var transactionVM: TransactionVM
    // Вью-модель аккаунтов, также @Bindable
    @Bindable var accountVM: AccountViewModel
    // Контекст модели из окружения SwiftData (если понадобится для операций)
    @Environment(\.modelContext) private var modelContext

    // Кастомный инициализатор позволяет передать начальную дату и вью-модели
    init(selectedDate: Date = Date(), transactionVM: TransactionVM, accountVM: AccountViewModel, path: Binding<[Route]>) {
        // Инициализируем @State через обертку State(initialValue:)
        self._selectedDate = State(initialValue: selectedDate)
        // Присваиваем переданные вью-модели
        self.transactionVM = transactionVM
        self.accountVM = accountVM
        // Инициализируем @Binding путь навигации
        self._path = path
    }

    // Вычисляемое свойство: список транзакций, отфильтрованных по выбранной дате и опциональному фильтру группы
    var filteredTransactions: [Transaction] {
        // Берем текущий календарь
        let calendar = Calendar.current
        // Начало суток выбранной даты
        let startOfDay = calendar.startOfDay(for: selectedDate)
        // Конец суток — начало следующих суток
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        // Копируем массив транзакций из вью-модели (в массив для удобства фильтрации/сортировки)
        var items: [Transaction] = Array(transactionVM.transactions)

        // Фильтруем по дате: транзакции, попадающие в выбранные сутки
        items = items.filter { (transaction: Transaction) -> Bool in
            transaction.date >= startOfDay && transaction.date < endOfDay
        }

        // Если выбран фильтр по группе — применяем его
        if let filter = selectedFilter {
            if filter == .transfer {
                // Для перевода — используем флаг isTransfer у транзакции
                items = items.filter { (tx: Transaction) -> Bool in
                    tx.isTransfer
                }
            } else {
                // Для доходов/расходов — сравниваем группу в доменной категории транзакции
                items = items.filter { (transaction: Transaction) -> Bool in
                    transaction.category.group == filter
                }
            }
        }
        // Сортируем по дате по убыванию (сначала более поздние)
        return items.sorted { (a: Transaction, b: Transaction) -> Bool in
            a.date > b.date
        }
    }

    // Основное тело вью
    var body: some View {
        ZStack {
            // Фоновый цвет из ассетов
            Color("фон")
                .ignoresSafeArea() // Растягиваем фон на всю область

            VStack {
                // Графический календарь для выбора даты
                VStack {
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .environment(\.locale, Locale(identifier: "ru_RU"))
                        .tint(Color.текст)
                    // Тонкая разделительная линия
                    Rectangle()
                        .fill(Color.текст)
                        .frame(height: 0.5)
                }
                .background(.ячейка)
                VStack {
                    // Горизонтальная полоса чипов фильтра по группе транзакций
                    HStack(spacing: 8) {
                        Button(action: { selectedFilter = nil }) {
                            FilterChip(
                                title: "Все",
                                icon: "tray.full",
                                color: .gray,
                                isSelected: selectedFilter == nil
                            )
                        }
                        ForEach(TransactionGroup.allCases, id: \.self) { group in
                            Button(action: { selectedFilter = group }) {
                                FilterChip(
                                    title: group.rawValue,
                                    icon: group.icon,
                                    color: group.color,
                                    isSelected: selectedFilter == group
                                )
                            }
                        }
                    }
                        .padding(.horizontal)

                    // Если после фильтрации транзакций нет — показываем пустое состояние
                    if filteredTransactions.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "list.bullet.rectangle")
                                .font(.system(size: 60))
                                .foregroundColor(.текст)
                                .padding(.top, 40)

                            Text("Нет транзакций")
                                .font(.title3)
                                .foregroundColor(.текст)

                            Text("Здесь появятся транзакции на выбранную дату")
                                .font(.callout)
                                .foregroundColor(.текст)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }

                    } else {
                        // Иначе — список транзакций за выбранную дату с учетом фильтра
                        List {
                            // Перебираем отфильтрованные транзакции
                            ForEach(filteredTransactions) { transaction in
                                Button {
                                    path.append(.transactionsDetail(transaction.id))
                                } label: {
                                    // Находим имя аккаунта по идентификатору транзакции
                                    let accountName = accountVM.accounts.first(where: { $0.id == transaction.accountId })?.name ?? "—"
                                    // Отображаем строку транзакции
                                    TransactionRow(transaction: transaction, accountName: accountName)
                                        .listRowSeparator(.hidden) // Прячем разделители
                                }
                                .listRowBackground(Color("фон")) // Важно: на уровне строки
                            }
                            // Встроенное удаление свайпом слева направо
                            .onDelete(perform: deleteTransaction)
                        }
                        .scrollContentBackground(.hidden)
                        .listStyle(.plain) // Плоский стиль списка
                        .background(Color("фон")) // Подкладываем фон под List
                    }
                    Spacer() // Заполняем оставшееся пространство
                }

            }
            .navigationTitle("Календарь") // Заголовок навигации
        }
    }

    // Обработчик удаления транзакций из списка
    private func deleteTransaction(_ offsets: IndexSet) {
        // Проходим по каждому индексу, который пользователь удалил
        for index in offsets {
            // Берем транзакцию из текущего отфильтрованного списка
            let transaction = filteredTransactions[index]
            // Удаляем транзакцию через вью-модель, которая также откатит баланс(ы) кошельков
            transactionVM.removeTransaction(transaction, accountVM: accountVM)
        }
    }
}
