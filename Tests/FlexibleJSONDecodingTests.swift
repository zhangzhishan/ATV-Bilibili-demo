import Foundation

private struct Fixture: Decodable {
    let value: Int?

    enum CodingKeys: String, CodingKey {
        case value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        value = container.decodeFlexibleIntIfPresent(forKey: .value)
    }
}

@main
enum FlexibleJSONDecodingTests {
    static func main() throws {
        let decoder = JSONDecoder()
        let cases: [(String, Int?)] = [
            (#"{"value": 42}"#, 42),
            (#"{"value": "42"}"#, 42),
            (#"{"value": null}"#, nil),
            (#"{"value": "not-a-number"}"#, nil),
            (#"{}"#, nil),
        ]

        for (json, expected) in cases {
            let fixture = try decoder.decode(Fixture.self, from: Data(json.utf8))
            precondition(fixture.value == expected, "Expected \(String(describing: expected)), got \(String(describing: fixture.value))")
        }

        precondition(FollowsFeedCompatibility.isPlayable(archiveAid: "42", pgcEpid: nil))
        precondition(FollowsFeedCompatibility.isPlayable(archiveAid: nil, pgcEpid: 42))
        precondition(!FollowsFeedCompatibility.isPlayable(archiveAid: "0", pgcEpid: nil))
        precondition(!FollowsFeedCompatibility.isPlayable(archiveAid: "bad", pgcEpid: nil))
        precondition(!FollowsFeedCompatibility.isPlayable(archiveAid: nil, pgcEpid: nil))

        precondition(FollowsFeedCompatibility.canAdvance(hasMore: true, currentOffset: "1", nextOffset: "2"))
        precondition(!FollowsFeedCompatibility.canAdvance(hasMore: false, currentOffset: "1", nextOffset: "2"))
        precondition(!FollowsFeedCompatibility.canAdvance(hasMore: true, currentOffset: "1", nextOffset: "1"))
        print("FlexibleJSONDecodingTests_OK")
    }
}
