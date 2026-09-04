import AVKit
import SwiftUI

struct FeedSubmissionCard: View {
    let submission: Submission

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("r/\(submission.subreddit) · u/\(submission.author)")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(submission.title)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            metadata

            if let selfText = submission.selfText {
                FeedMarkdownBody(source: selfText)
                    .lineLimit(10)
            }

            if !submission.gallery.isEmpty {
                FeedGallery(images: submission.gallery)
            }

            if let video = submission.video {
                FeedVideo(video: video)
            }
        }
        .padding(.vertical, 8)
    }

    private var metadata: some View {
        HStack(spacing: 8) {
            if submission.isNsfw { tag("NSFW") }
            if submission.isPinned { tag("Pinned") }
            if submission.isStickied { tag("Stickied") }
            Text("↑ \(submission.score)")
            Text("💬 \(submission.commentCount)")
            Text(RelativeTime.string(from: submission.created))
            Spacer(minLength: 0)
        }
        .font(.caption2)
        .foregroundStyle(.secondary)
    }

    private func tag(_ text: String) -> some View {
        Text(text)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(.quaternary, in: Capsule())
    }
}

struct FeedGallery: View {
    let images: [GalleryImage]

    var body: some View {
        TabView {
            ForEach(Array(images.enumerated()), id: \.element.id) { index, image in
                AsyncImage(url: image.url) { phase in
                    switch phase {
                    case let .success(img):
                        img.resizable().scaledToFit()
                    case .failure:
                        Color.secondary.opacity(0.2)
                    default:
                        ProgressView()
                    }
                }
                .overlay(alignment: .bottomTrailing) {
                    Text("\(index + 1) / \(images.count)")
                        .font(.caption2)
                        .padding(6)
                        .background(.thinMaterial, in: Capsule())
                        .padding(8)
                }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(minHeight: 220)
    }
}

struct FeedVideo: View {
    let video: VideoMedia
    @State private var player: AVPlayer?

    var body: some View {
        Group {
            if let player {
                VideoPlayer(player: player)
                    .aspectRatio(video.aspectRatio, contentMode: .fit)
            } else {
                Color.secondary.opacity(0.15)
                    .aspectRatio(video.aspectRatio, contentMode: .fit)
                    .overlay { ProgressView() }
            }
        }
        .onAppear {
            if player == nil {
                let av = AVPlayer(url: video.url)
                av.pause()
                player = av
            }
        }
        .onDisappear {
            player?.pause()
        }
    }
}
