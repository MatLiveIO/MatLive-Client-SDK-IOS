//
//  chatMessageView.swift
//  MatLive-Client-SDK_IOS
//
//  Created by anas amer on 31/12/2024.
//

import Foundation
import SwiftUI


struct ChatMessageWidget: View {
    let message: MatLiveChatMessage

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                AsyncImage(url: URL(string: message.user.avatar)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .frame(width: 25, height: 25)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 25, height: 25)
                    }
                }
                Text(message.user.name)
                    .font(.headline)
            }

            Text(message.message)
                .font(.body)
        }
    }
}
