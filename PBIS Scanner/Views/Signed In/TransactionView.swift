//
//  TransactionView.swift
//  PBIS Scanner
//
//  Created by Jaron Schreiber on 10/31/20.
//  Copyright © 2020 DxHub. All rights reserved.
//

import SwiftUI

struct TransactionView: View {
    let juvenile: Juvenile
    var transactions: [Transaction] = []
    
    var body: some View {
        List {
//            ForEach(transactions, id: \.id, content: { transaction in
//                Text(transaction.id)
//            })
//            .navigationBarTitle(juvenile.first_name)
        }
        .onAppear {

        }
    }
}
