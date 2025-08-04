//
//  AuthenticationView.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import SwiftUI

struct AuthenticationView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    
    let gradientStart = Color(hex: "#94A684").opacity(0.7)
    let gradientEnd = Color(hex: "#94A684").opacity(0.0)
    
    @ObservedObject var viewModel: AuthenticationViewModel
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [gradientStart, gradientEnd]), startPoint: .top, endPoint: .bottomLeading)
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                Image(systemName: "person.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                Text("Welcome !")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                TextField("Adresse email", text: $viewModel.username)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .disableAutocorrection(true)
                SecureField("Mot de passe", text: $viewModel.password)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
                Button(action: {
                    Task {
                        await viewModel.login()
                    }
                }) {
                    Text("Se connecter")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 40)
        }
        .onTapGesture {
            self.endEditing(true)
        }
    }
}
