import SwiftUI

struct AvatarView: View {
    let url: URL?
    let size: CGFloat
    let refreshId: UUID

    @StateObject private var loader = ImageLoader()

    var body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.25))
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.gray.opacity(0.6))
                    )
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .onAppear { loader.load(url: url, force: true) }
        .onChange(of: refreshId) { _, _ in
            loader.load(url: url, force: true)
        }
        .onChange(of: url) { _, newUrl in
            loader.load(url: newUrl, force: true)
        }
    }
}

// MARK: - ImageLoader (cache bypass)
@MainActor
final class ImageLoader: ObservableObject {
    @Published var image: UIImage?

    private var task: Task<Void, Never>?

    func load(url: URL?, force: Bool) {
        task?.cancel()
        image = nil

        guard let url else { return }

        task = Task {
            do {
                var req = URLRequest(url: url)
                req.cachePolicy = .reloadIgnoringLocalCacheData
                req.timeoutInterval = 30

                let config = URLSessionConfiguration.ephemeral
                config.requestCachePolicy = .reloadIgnoringLocalCacheData
                config.urlCache = nil

                let session = URLSession(configuration: config)

                let (data, resp) = try await session.data(for: req)

                if Task.isCancelled { return }

                if let http = resp as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                    print("Avatar HTTP:", http.statusCode, "url:", url.absoluteString)
                    return
                }

                guard let ui = UIImage(data: data) else {
                    print("Avatar decode fail, bytes:", data.count, "url:", url.absoluteString)
                    return
                }

                self.image = ui
            } catch {
                if (error as? URLError)?.code == .cancelled { return }
                print(" Avatar load error:", error.localizedDescription, "url:", url.absoluteString)
            }
        }
    }
}
