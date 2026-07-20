//
//  WhatsNewView.swift
//  BlackSwan
//
//  Created by Giuseppe Cosenza on 20/07/26.
//

import SwiftUI

struct WhatsNewView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var contentVisible = false
    @State private var iconBounce = 0
    
    private let features: [WhatsNewFeature] = [
        WhatsNewFeature(
            icon: "chart.line.uptrend.xyaxis",
            title: "Fragility score",
            detail: "See weak spots by theme and how your exposure shifts over weeks."
        ),
        WhatsNewFeature(
            icon: "calendar.badge.clock",
            title: "Weekly review",
            detail: "A 7-day ritual with focus, wins, and open protections."
        ),
        WhatsNewFeature(
            icon: "shield.lefthalf.filled",
            title: "Pre-mortems",
            detail: "Plan buffers before the next surprise — then check them off."
        ),
        WhatsNewFeature(
            icon: "checklist",
            title: "Mitigation checklists",
            detail: "Mark protections done on events so fragility actually falls."
        )
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    header
                        .padding(.top, 8)
                    
                    VStack(spacing: 12) {
                        ForEach(Array(features.enumerated()), id: \.element.id) { index, feature in
                            featureRow(feature)
                                .opacity(contentVisible ? 1 : 0)
                                .offset(y: contentVisible ? 0 : 14)
                                .animation(
                                    .spring(response: 0.48, dampingFraction: 0.82)
                                        .delay(0.08 + Double(index) * 0.05),
                                    value: contentVisible
                                )
                        }
                    }
                    
                    Text("Follow the tips on Home for a quick guided tour.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                        .opacity(contentVisible ? 1 : 0)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .background {
                ZStack {
                    LinearGradient(
                        colors: [
                            Color(.systemBackground),
                            Color.blue.opacity(0.06),
                            Color(.secondarySystemBackground).opacity(0.7)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 260, height: 260)
                        .blur(radius: 56)
                        .offset(x: 100, y: -160)
                }
                .ignoresSafeArea()
            }
            .safeAreaInset(edge: .bottom) {
                Button {
                    dismiss()
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                .padding(.top, 8)
                .background(.ultraThinMaterial)
            }
            .navigationTitle("What’s New")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.82).delay(0.05)) {
                contentVisible = true
            }
            iconBounce += 1
        }
    }
    
    private var header: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 96, height: 96)
                    .overlay {
                        Circle()
                            .strokeBorder(Color.blue.opacity(0.2), lineWidth: 1)
                    }
                
                Circle()
                    .fill(Color.blue.opacity(0.12))
                    .frame(width: 72, height: 72)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(.blue)
                    .symbolRenderingMode(.hierarchical)
                    .symbolEffect(.bounce, value: iconBounce)
            }
            .opacity(contentVisible ? 1 : 0)
            .scaleEffect(contentVisible ? 1 : 0.85)
            
            VStack(spacing: 8) {
                Text("Black Swan \(AppVersion.marketing)")
                    .font(.title2.bold())
                
                Text("A tighter loop for spotting fragile spots and limiting damage from surprise.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .opacity(contentVisible ? 1 : 0)
            .offset(y: contentVisible ? 0 : 12)
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.84), value: contentVisible)
    }
    
    private func featureRow(_ feature: WhatsNewFeature) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: feature.icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(.blue)
                .frame(width: 28, height: 28)
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(feature.title)
                    .font(.subheadline.weight(.semibold))
                
                Text(feature.detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.blue.opacity(0.1), lineWidth: 1)
        }
    }
}

private struct WhatsNewFeature: Identifiable {
    var id: String { title }
    let icon: String
    let title: String
    let detail: String
}

enum AppVersion {
    static var marketing: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}

#Preview {
    WhatsNewView()
}
