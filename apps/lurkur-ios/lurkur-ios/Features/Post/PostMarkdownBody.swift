import SwiftUI

struct PostMarkdownBody: View {
    let source: String

    var body: some View {
        Text(attributed)
            .textSelection(.enabled)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var attributed: AttributedString {
        if let parsed = try? AttributedString(
            markdown: source,
            options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        ) {
            return parsed
        }
        return AttributedString(source)
    }
}

struct PostCommentBody: View {
    let bodyText: String

    var body: some View {
        if bodyText.hasPrefix("https://preview.redd.it/"),
           let first = bodyText.split(whereSeparator: \.isWhitespace).first,
           let url = URL(string: String(first))
        {
            AsyncImage(url: url) { phase in
                switch phase {
                case let .success(image):
                    image.resizable().scaledToFit()
                case .failure:
                    PostMarkdownBody(source: bodyText)
                default:
                    ProgressView()
                }
            }
        } else {
            PostMarkdownBody(source: bodyText)
        }
    }
}
