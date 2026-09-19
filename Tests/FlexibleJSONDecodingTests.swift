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
        print("FlexibleJSONDecodingTests_OK")
    }
}
