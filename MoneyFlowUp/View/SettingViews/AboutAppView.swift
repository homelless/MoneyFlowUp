import SwiftUI

struct AboutAppView: View {
    var body: some View {
        ZStack {
            Color("фон").ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Об этом приложении")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.текст2)

                    Text("MoneyFlowUp - это простое и наглядное приложение для учета личных финансов. Добавляйте доходы и расходы, переводите средства между кошельками, анализируйте структуру трат по категориям и следите за динамикой.")
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundStyle(.текст)

                    Group {
                        Text("Возможности")
                            .font(.title3.bold())
                            .foregroundStyle(.текст2)

                        Text("• Множество кошельков и категорий \n• Быстрое добавление трат, доходов и переводов\n• Календарь операций по дням\n• Отчеты и диаграммы по категориям\n• Фильтры и период для анализа\n• Локальное хранение данных")
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundStyle(.текст)

                    }

                    Group {
                        Text("Приватность и данные")
                            .font(.title3.bold())
                            .foregroundStyle(.текст2)

                        Text("Все ваши данные хранятся локально на устройстве с использованием базы данных. Приложение не передает финансовую информацию на внешние серверы.")
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundStyle(.текст)

                    }

                    Group {
                        Text("Поддержка")
                            .font(.title3.bold())
                            .foregroundStyle(.текст2)

                        Text("Если у вас есть предложения или вы нашли ошибку, пожалуйста, свяжитесь с разработчиком. Спасибо за обратную связь — она помогает делать приложение лучше.")
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundStyle(.текст)

                    }

                    Group {
                        Text("Автор")
                            .font(.title3.bold())
                            .foregroundStyle(.текст2)

                        Text("Саркулов Владислав.\nтелеграмм: @homeless_ss \nинстаграмм: @homeless_ss")
                            .font(.body)
                            .italic()
                            .foregroundStyle(.текст)

                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    AboutAppView()
}
