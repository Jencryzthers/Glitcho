import SwiftUI
import WebKit

struct ContentView: View {
    @StateObject private var store = WebViewStore(url: URL(string: "https://www.twitch.tv")!)
    @State private var searchText = ""
    @State private var showSettingsPopup = false
    @State private var currentChannel: String?
    @State private var useNativePlayer = false
    @State private var playerID = UUID() // Pour forcer le refresh

    var body: some View {
        ZStack {
            GlassBackground()

            NavigationSplitView(columnVisibility: .constant(.all)) {
                Sidebar(
                    searchText: $searchText,
                    store: store,
                    showSettingsPopup: $showSettingsPopup,
                    onChannelSelected: { channelName in
                        currentChannel = channelName
                        useNativePlayer = true
                        playerID = UUID() // Force le refresh de la vue
                    }
                )
                .navigationSplitViewColumnWidth(350)
            } detail: {
                GlassCard {
                    if useNativePlayer, let channel = currentChannel {
                        HybridTwitchView(channelName: channel)
                            .id(playerID) // Force SwiftUI à recréer la vue
                    } else {
                        WebViewContainer(webView: store.webView)
                    }
                }
                .shadow(color: Color.black.opacity(0.28), radius: 30, x: 0, y: 16)
                .padding(20)
            }
            .navigationSplitViewStyle(.prominentDetail)
            .onChange(of: store.shouldSwitchToNativePlayer) { channelName in
                if let channel = channelName {
                    currentChannel = channel
                    useNativePlayer = true
                    playerID = UUID()
                    // Réinitialiser le flag
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        store.shouldSwitchToNativePlayer = nil
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 325, ideal: 325, max: 325)

            if showSettingsPopup {
                PopupPanel(
                    title: "Settings",
                    width: 760,
                    height: 700,
                    url: URL(string: "https://www.twitch.tv/settings")!,
                    onLoadScript: settingsPopupScript
                ) {
                    showSettingsPopup = false
                }
                .zIndex(2)
            }
        }
    }
}

private let settingsPopupScript = """
(function() {
  const css = `
    :root {
      --side-nav-width: 0px !important;
      --side-nav-width-collapsed: 0px !important;
      --side-nav-width-expanded: 0px !important;
      --left-nav-width: 0px !important;
      --top-nav-height: 0px !important;
    }
    header,
    .top-nav,
    .top-nav__menu,
    [data-a-target="top-nav-container"],
    [data-test-selector="top-nav-container"],
    [data-test-selector="top-nav"],
    [data-a-target="top-nav"],
    #sideNav,
    [data-a-target="left-nav"],
    [data-test-selector="left-nav"],
    [data-a-target="side-nav"],
    [data-a-target="side-nav-bar"],
    [data-a-target="side-nav-bar__content"],
    [data-a-target="side-nav-bar__content__inner"],
    [data-a-target="side-nav-bar__overlay"],
    [data-a-target="side-nav__content"],
    [data-a-target="side-nav-container"],
    [data-test-selector="side-nav"],
    nav[aria-label="Primary Navigation"] {
      display: none !important;
      width: 0 !important;
      min-width: 0 !important;
      max-width: 0 !important;
      opacity: 0 !important;
      pointer-events: none !important;
    }
    main,
    [data-a-target="page-layout__main"],
    [data-a-target="page-layout__main-content"],
    [data-a-target="content"] {
      margin-left: 0 !important;
      padding-left: 0 !important;
      margin-top: 0 !important;
      padding-top: 0 !important;
      background: transparent !important;
    }
    body, #root {
      background: transparent !important;
    }
    [data-a-target="user-menu"],
    [data-test-selector="user-menu"],
    [data-a-target="user-menu-dropdown"],
    [data-test-selector="user-menu-dropdown"],
    [data-a-target="user-menu-overlay"],
    [data-test-selector="user-menu-overlay"] {
      display: none !important;
    }
    [data-a-target="settings-layout"],
    [data-test-selector="settings-layout"],
    [data-a-target="settings-content"],
    [data-test-selector="settings-content"] {
      margin: 0 !important;
      padding: 0 !important;
      max-width: 100% !important;
    }
  `;
  let style = document.getElementById('tw-popup-style');
  if (!style) {
    style = document.createElement('style');
    style.id = 'tw-popup-style';
    style.textContent = css;
    document.head.appendChild(style);
  }
})();
"""

struct Sidebar: View {
    @Binding var searchText: String
    @ObservedObject var store: WebViewStore
    @Binding var showSettingsPopup: Bool
    var onChannelSelected: ((String) -> Void)?

    private let sections: [TwitchDestination] = [
        .home,
        .following,
        .browse,
        .categories,
        .music,
        .esports,
        .drops
    ]

    var body: some View {
        VStack(spacing: 12) {
            GlassCard {
                VStack(spacing: 12) {
                    LogoHeader()

                    AccountSection(
                        store: store,
                        showSettingsPopup: $showSettingsPopup
                    )

                    SearchBar(text: $searchText) {
                        let query = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                        store.navigate(to: URL(string: "https://www.twitch.tv/search?term=\(query)")!)
                    }

                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 20) {
                            SidebarSection(title: "EXPLORE") {
                                VStack(spacing: 2) {
                                    ForEach(sections) { destination in
                                        SidebarRow(
                                            title: destination.title,
                                            systemImage: destination.icon
                                        ) {
                                            store.navigate(to: destination.url)
                                        }
                                    }
                                }
                            }

                            SidebarSection(title: "FOLLOWING") {
                                if store.followedLive.isEmpty {
                                    HStack(spacing: 8) {
                                        Image(systemName: "heart")
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundStyle(.white.opacity(0.4))
                                        Text("No live channels")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundStyle(.white.opacity(0.5))
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 8)
                                } else {
                                    VStack(spacing: 2) {
                                    ForEach(store.followedLive) { channel in
                                        FollowingRow(channel: channel) {
                                            // Extraire le nom de la chaîne depuis l'URL
                                            let channelName = channel.url.lastPathComponent
                                            onChannelSelected?(channelName)
                                        }
                                    }
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .scrollIndicators(.visible)
                }
                .padding(14)
            }
            .shadow(color: Color.black.opacity(0.25), radius: 20, x: 0, y: 10)
        }
        .padding(20)
    }
}

struct LogoHeader: View {
    var body: some View {
        HStack(spacing: 0) {
            if let image = NSImage(contentsOfFile: "/Users/Repository/twitchapp/Resources/sidebar_logo.png") {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 28)
            } else {
                // Fallback avec texte si l'image n'existe pas
                Text("twitch")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 0.58, green: 0.25, blue: 0.82),
                                Color(red: 0.48, green: 0.18, blue: 0.72)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            Spacer()
        }
        .padding(.bottom, 8)
    }
}

struct AccountSection: View {
    @ObservedObject var store: WebViewStore
    @Binding var showSettingsPopup: Bool

    var body: some View {
        let displayName = normalized(store.profileName) ?? normalized(store.profileLogin) ?? (store.isLoggedIn ? "Profile" : "Not signed in")
        let subtitle: String = {
            guard store.isLoggedIn else { return "Sign in to continue" }
            if let login = normalized(store.profileLogin) {
                return "@\(login)"
            }
            return "Account"
        }()

        VStack(spacing: 12) {
            HStack(spacing: 12) {
                AvatarView(url: store.profileAvatarURL, isLoggedIn: store.isLoggedIn)
                VStack(alignment: .leading, spacing: 3) {
                    Text(displayName)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    Text(subtitle)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
            }
            
            HStack(spacing: 8) {
                if store.isLoggedIn {
                    Button {
                        showSettingsPopup = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 11, weight: .semibold))
                            Text("Settings")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.white.opacity(0.12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .stroke(Color.white.opacity(0.16), lineWidth: 0.5)
                                )
                        )
                    }
                    .buttonStyle(.plain)

                    Button {
                        store.logout()
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.85))
                            .frame(width: 32, height: 32)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .stroke(Color.white.opacity(0.14), lineWidth: 0.5)
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                    .help("Log out")
                } else {
                    Button {
                        store.navigate(to: URL(string: "https://www.twitch.tv/login")!)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 11, weight: .semibold))
                            Text("Log in")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.58, green: 0.25, blue: 0.82),
                                            Color(red: 0.48, green: 0.18, blue: 0.72)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                                )
                                .shadow(color: Color(red: 0.58, green: 0.25, blue: 0.82).opacity(0.4), radius: 8, x: 0, y: 4)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
                )
        )
    }

    private func normalized(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return nil }
        let lower = trimmed.lowercased()
        if ["user", "profile", "account", "avatar", "menu", "user menu"].contains(lower) {
            return nil
        }
        return trimmed
    }
}

struct AvatarView: View {
    let url: URL?
    let isLoggedIn: Bool

    var body: some View {
        Group {
            if let url = url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .failure:
                        ZStack {
                            Color.white.opacity(0.12)
                            Image(systemName: "person.fill")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    default:
                        ZStack {
                            Color.white.opacity(0.08)
                            ProgressView()
                                .scaleEffect(0.6)
                                .tint(.white.opacity(0.5))
                        }
                    }
                }
            } else {
                ZStack {
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.14),
                            Color.white.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    Image(systemName: isLoggedIn ? "person.fill" : "person")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.65))
                }
            }
        }
        .frame(width: 40, height: 40)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.2),
                            Color.white.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
    }
}

struct TwitchDestination: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let url: URL
    let icon: String

    static let home = TwitchDestination(title: "Home", url: URL(string: "https://www.twitch.tv")!, icon: "house")
    static let following = TwitchDestination(title: "Following", url: URL(string: "https://www.twitch.tv/directory/following")!, icon: "heart")
    static let browse = TwitchDestination(title: "Browse", url: URL(string: "https://www.twitch.tv/directory")!, icon: "sparkles.tv")
    static let categories = TwitchDestination(title: "Categories", url: URL(string: "https://www.twitch.tv/directory/categories")!, icon: "rectangle.grid.2x2")
    static let music = TwitchDestination(title: "Music", url: URL(string: "https://www.twitch.tv/directory/category/music")!, icon: "music.note")
    static let esports = TwitchDestination(title: "Esports", url: URL(string: "https://www.twitch.tv/directory/category/esports")!, icon: "trophy")
    static let drops = TwitchDestination(title: "Drops", url: URL(string: "https://www.twitch.tv/drops")!, icon: "gift")
}

struct GlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .background(
                ZStack {
                    // Fond moins transparent
                    Color(red: 0.08, green: 0.08, blue: 0.12)
                        .opacity(0.75)
                    
                    // Effet de verre subtil
                    VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)
                        .opacity(0.3)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.08),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .blur(radius: 2)
            )
    }
}

struct SearchBar: View {
    @Binding var text: String
    let onSubmit: () -> Void
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isFocused ? Color.white.opacity(0.9) : Color.white.opacity(0.5))

            TextField("Search Twitch", text: $text)
                .textFieldStyle(.plain)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.primary)
                .focused($isFocused)
                .onSubmit(onSubmit)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.4))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(isFocused ? 0.14 : 0.10))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(
                            isFocused 
                                ? Color.white.opacity(0.3)
                                : Color.white.opacity(0.18),
                            lineWidth: isFocused ? 1 : 0.5
                        )
                )
        )
        .animation(.easeInOut(duration: 0.15), value: isFocused)
    }
}

struct SidebarSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Color.white.opacity(0.4))
                .tracking(0.5)
                .padding(.horizontal, 10)
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SidebarRow: View {
    let title: String
    let systemImage: String
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(isHovered ? Color.white.opacity(0.9) : Color.white.opacity(0.6))
                    .frame(width: 18)
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isHovered ? .primary : Color.white.opacity(0.85))
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isHovered ? Color.white.opacity(0.08) : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}

struct FollowingRow: View {
    let channel: TwitchChannel
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                ChannelThumbnail(url: channel.thumbnailURL)
                VStack(alignment: .leading, spacing: 2) {
                    Text(channel.name)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(isHovered ? .primary : Color.white.opacity(0.85))
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 6, height: 6)
                    Text("LIVE")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.red)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(
                    Capsule()
                        .fill(Color.red.opacity(0.15))
                )
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isHovered ? Color.white.opacity(0.08) : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}

struct ChannelThumbnail: View {
    let url: URL?

    var body: some View {
        Group {
            if let url = url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .failure:
                        ZStack {
                            Color.white.opacity(0.1)
                            Image(systemName: "person.fill")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(Color.white.opacity(0.4))
                        }
                    default:
                        ZStack {
                            Color.white.opacity(0.08)
                            ProgressView()
                                .scaleEffect(0.5)
                                .tint(Color.white.opacity(0.4))
                        }
                    }
                }
            } else {
                ZStack {
                    Color.white.opacity(0.1)
                    Image(systemName: "person.fill")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.4))
                }
            }
        }
        .frame(width: 36, height: 36)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.2),
                            Color.white.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

struct WebViewContainer: NSViewRepresentable {
    let webView: WKWebView

    func makeNSView(context: Context) -> WKWebView {
        webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        _ = nsView
    }
}

struct PopupWebViewContainer: NSViewRepresentable {
    let url: URL
    let onLoadScript: String?

    func makeCoordinator() -> Coordinator {
        Coordinator(onLoadScript: onLoadScript)
    }

    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        config.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.setValue(false, forKey: "drawsBackground")
        if #available(macOS 12.0, *) {
            webView.underPageBackgroundColor = .clear
        }
        webView.customUserAgent = WebViewStore.safariUserAgent
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        if nsView.url != url {
            nsView.load(URLRequest(url: url))
        }
        context.coordinator.onLoadScript = onLoadScript
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        var onLoadScript: String?

        init(onLoadScript: String?) {
            self.onLoadScript = onLoadScript
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            guard let script = onLoadScript else { return }
            webView.evaluateJavaScript(script, completionHandler: nil)
        }
    }
}

struct PopupPanel: View {
    let title: String
    let width: CGFloat
    let height: CGFloat
    let url: URL
    let onLoadScript: String?
    let onClose: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture(perform: onClose)

            GlassCard {
                VStack(spacing: 12) {
                    HStack {
                        Text(title)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.primary)
                        Spacer()
                        Button(action: onClose) {
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 12)

                    PopupWebViewContainer(url: url, onLoadScript: onLoadScript)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .padding(.horizontal, 12)
                        .padding(.bottom, 12)
                }
            }
            .frame(width: width, height: height)
            .shadow(color: Color.black.opacity(0.3), radius: 26, x: 0, y: 16)
        }
    }
}

struct GlassBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.12, blue: 0.18),
                    Color(red: 0.14, green: 0.08, blue: 0.2),
                    Color(red: 0.06, green: 0.18, blue: 0.16)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [
                    Color.white.opacity(0.25),
                    Color.white.opacity(0.02)
                ],
                center: .topLeading,
                startRadius: 20,
                endRadius: 500
            )
            .blendMode(.screen)

            VisualEffectView(material: .underWindowBackground, blendingMode: .behindWindow)
                .opacity(0.9)
        }
        .ignoresSafeArea()
    }
}

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
