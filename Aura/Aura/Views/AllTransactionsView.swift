//
//  AllTransactionsView.swift
//  Aura
//
//  Created by Renaud Leroy on 18/06/2025.
//

import SwiftUI



struct AllTransactionsView: View {
    
    @ObservedObject private var viewModel = AllTransactionsViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            // Large Header displaying total amount
            VStack(spacing: 10) {
                Text("Your Balance")
                    .font(.headline)
                Text(String(format: "%.2f", viewModel.currentBalance))
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(Color(hex: "#94A684")) // Using the green color you provided
                Image(systemName: "eurosign.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)
                    .foregroundColor(Color(hex: "#94A684"))
            }
        }
        .padding(.bottom)
        List(viewModel.transactions, id: \.label) { transaction in
            HStack {
                Image(systemName: transaction.value > 0 ? "arrow.up.right.circle.fill" : "arrow.down.left.circle.fill")
                    .foregroundColor(transaction.value > 0 ? .green : .red)
                Text(transaction.label)
                Spacer()
                Text(String(format: "%.2f", transaction.value))
                    .fontWeight(.bold)
                    .foregroundColor(transaction.value > 0 ? .green : .red)
            }
            .padding()
        }
        .onAppear {
            viewModel.allTransactions()
        }
    }
}


#Preview {
    AllTransactionsView()
}
