//
//  AccountDetailView.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import SwiftUI

struct AccountDetailView: View {
    @ObservedObject var viewModel: AccountViewModel
    @State var showAllTransactionsView: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(spacing: 10) {
                    Text("Your Balance")
                        .font(.headline)
                    Text(String(format: "%.2f", viewModel.currentBalance))
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(Color(hex: "#94A684"))
                    Image(systemName: "eurosign.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 80)
                        .foregroundColor(Color(hex: "#94A684"))
                }
                .padding(.top)
                VStack(alignment: .leading, spacing: 10) {
                    Text("Recent Transactions")
                        .font(.headline)
                        .padding([.horizontal])
                    ForEach(viewModel.transactions.prefix(3), id: \.label) { transaction in
                        HStack {
                            Image(systemName: transaction.value > 0 ? "arrow.up.right.circle.fill" : "arrow.down.left.circle.fill")
                                .foregroundColor(transaction.value > 0 ? .green : .red)
                            Text(transaction.label)
                            Spacer()
                            Text(String(format: "%.2f €", transaction.value))
                                .fontWeight(.bold)
                                .foregroundColor(transaction.value > 0 ? .green : .red)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .padding([.horizontal])
                    }
                }
                Button(action: {showAllTransactionsView.toggle()   
                }) {
                    HStack {
                        Image(systemName: "list.bullet")
                        Text("See Transaction Details")
                    }
                    .padding()
                    .background(Color(hex: "#94A684"))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding([.horizontal, .bottom])
                Spacer()
            }
            .onTapGesture {
                self.endEditing(true)
            }
            .onAppear {
                Task {
                    await viewModel.account()
                }
            }
            .navigationDestination(isPresented: $showAllTransactionsView) {
                AllTransactionsView(viewModel: AllTransactionsViewModel(keychainService: AuraKeychainService(), apiService: AuraAPIService()))
            }
        }
    }
}


