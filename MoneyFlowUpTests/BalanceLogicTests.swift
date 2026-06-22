import Testing
import Foundation
import SwiftData
@testable import MoneyFlowUp

// Тесты единого источника расчёта баланса (AccountViewModel.apply/revert),
// переводов, каскадного удаления и точности Decimal.
@MainActor
struct BalanceLogicTests {

    // Свежий in-memory контекст SwiftData со схемой приложения.
    private func makeContext() throws -> ModelContext {
        let schema = Schema([
            Transaction.self,
            Account.self,
            CustomCostCategory.self,
            CustomIncomeCategory.self,
            HiddenCategory.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        return ModelContext(container)
    }

    // Вставляет аккаунт и возвращает (VM, account) с уже загруженным списком.
    private func makeAccount(_ ctx: ModelContext, balance: Decimal, name: String = "A") -> (AccountViewModel, Account) {
        let acc = Account(id: UUID(), name: name, balance: balance, currencyRaw: "$", descriptionAccount: "")
        ctx.insert(acc)
        try? ctx.save()
        let vm = AccountViewModel(context: ctx)
        return (vm, acc)
    }

    private var anyCost: CostCategory { CostCategory.all.first! }
    private var anyIncome: IncomeCategory { IncomeCategory.all.first! }

    @Test func costReducesBalance() throws {
        let ctx = try makeContext()
        let (vm, acc) = makeAccount(ctx, balance: 100)
        let tx = Transaction(id: UUID(), amount: 30, category: .cost(anyCost), date: .now, account: acc)
        vm.apply(tx)
        #expect(vm.accounts.first?.balance == Decimal(70))
    }

    @Test func incomeIncreasesBalance() throws {
        let ctx = try makeContext()
        let (vm, acc) = makeAccount(ctx, balance: 100)
        let tx = Transaction(id: UUID(), amount: 50, category: .income(anyIncome), date: .now, account: acc)
        vm.apply(tx)
        #expect(vm.accounts.first?.balance == Decimal(150))
    }

    @Test func transferMovesMoneyBetweenAccounts() throws {
        let ctx = try makeContext()
        let from = Account(id: UUID(), name: "From", balance: 100, currencyRaw: "$", descriptionAccount: "")
        let to = Account(id: UUID(), name: "To", balance: 20, currencyRaw: "$", descriptionAccount: "")
        ctx.insert(from); ctx.insert(to); try? ctx.save()
        let vm = AccountViewModel(context: ctx)

        let tx = Transaction(id: UUID(), amount: 30, category: .transfer(.accountTransfer), date: .now, account: from, toAccount: to)
        vm.apply(tx)

        #expect(vm.accounts.first(where: { $0.id == from.id })?.balance == Decimal(70))
        #expect(vm.accounts.first(where: { $0.id == to.id })?.balance == Decimal(50))
    }

    @Test func revertUndoesApply() throws {
        let ctx = try makeContext()
        let (vm, acc) = makeAccount(ctx, balance: 100)
        let tx = Transaction(id: UUID(), amount: 30, category: .cost(anyCost), date: .now, account: acc)
        vm.apply(tx)
        vm.revert(tx)
        #expect(vm.accounts.first?.balance == Decimal(100))
    }

    // Ключевой тест точности: 0.1 трижды не должно «плыть» (в Double дало бы 0.30000000000000004).
    @Test func applyDoesNotDriftOnRepeatedDecimals() throws {
        let ctx = try makeContext()
        let (vm, acc) = makeAccount(ctx, balance: 0)
        for _ in 0..<3 {
            let tx = Transaction(id: UUID(), amount: 0.1, category: .cost(anyCost), date: .now, account: acc)
            vm.apply(tx)
        }
        #expect(vm.accounts.first?.balance == Decimal(string: "-0.3"))
    }

    @Test func deletingAccountCascadesTransactions() throws {
        let ctx = try makeContext()
        let (vm, acc) = makeAccount(ctx, balance: 100)
        let tx = Transaction(id: UUID(), amount: 30, category: .cost(anyCost), date: .now, account: acc)
        ctx.insert(tx); try? ctx.save()

        #expect((try? ctx.fetchCount(FetchDescriptor<Transaction>())) == 1)
        vm.removeAccount(id: acc.id)
        #expect((try? ctx.fetchCount(FetchDescriptor<Transaction>())) == 0)
    }

    @Test func removeTransactionRevertsBalance() throws {
        let ctx = try makeContext()
        let (accVM, acc) = makeAccount(ctx, balance: 100)
        let txVM = TransactionVM(context: ctx)

        let tx = Transaction(id: UUID(), amount: 40, category: .cost(anyCost), date: .now, account: acc)
        accVM.apply(tx)
        txVM.addTransaction(tx)
        #expect(accVM.accounts.first?.balance == Decimal(60))

        txVM.removeTransaction(tx, accountVM: accVM)
        #expect(accVM.accounts.first?.balance == Decimal(100))
    }
}
