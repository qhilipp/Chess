//
//  CopyableText.swift
//  Chess
//
//  Created by Privat on 20.04.25.
//

import SwiftUI

struct CopyableTokenView: View {
    
    let text: String
    @State private var copied = false

    var body: some View {
        Text(text)
            .textSelection(.disabled)
            .onTapGesture {
                copyToPasteboard(text)
                withAnimation {
                    copied = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        copied = false
                    }
                }
            }
            .opacity(copied ? 0 : 1)
            .overlay {
                if copied {
                    Label("Copied", systemImage: "document.on.document.fill")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color(.secondarySystemFill)))
                }
            }
        .animation(.easeInOut, value: copied)
    }

    private func copyToPasteboard(_ string: String) {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(string, forType: .string)
        #else
        UIPasteboard.general.string = string
        #endif
    }
}
