//
//  GitHub.swift
//  CheapHub
//
//  Created by GK on 2018/8/15.
//  Copyright © 2018年 com.gk. All rights reserved.
//

import Moya
import Foundation

public enum GitHub {
    case upload(data: Data)
    case download(String)
}

private extension String {
    var urlEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
    }
}
public func url(_ route: TargetType) -> String {
    return route.baseURL.appendingPathComponent(route.path).absoluteString
}

extension Moya.Response {
    func mapNSArray() throws -> NSArray {
        let any = try self.mapJSON()
        guard let array = any as? NSArray else {
            throw MoyaError.jsonMapping(self)
        }
        return array
    }
}
extension GitHub: TargetType {
    
    public var baseURL: URL {
        switch self {
        case .upload:
            return URL(string: "https://upload.giphy.com")!
        case .download:
            return URL(string: "https://raw.githubusercontent.com")!
        }
    }

    public var path: String {
        switch self {
        case .upload:
            return "/v1/gjfs"
        case .download(let contentPath):
            return "/Moya/Moya/master/web/\(contentPath)"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .upload:
            return .post
        default:
            return .get
        }
    }

    public var sampleData: Data {
        switch self {
        case .upload:
            return "{\"data\":{\"id\":\"your_new_gif_id\"},\"meta\":{\"status\":200,\"msg\":\"OK\"}}".data(using: String.Encoding.utf8)!
        case .download:
            return TestData.animatedBirdData
        }
    }

    public var task: Task {
        switch self {
        case .upload(let data):
            let multipartFormData = MultipartFormData(provider: MultipartFormData.FormDataProvider.data(data), name: "file", fileName: "gif.gjf", mimeType: "image/gjf")
            return .uploadCompositeMultipart([multipartFormData], urlParameters: ["api_key": "dc6zaTOxFJmzC", "username": "Moya"])
        case .download:
            return .downloadDestination(defaultDownloadDestination)
        }
    }
   
    public var headers: [String : String]? {
        switch self {
        case .upload, .download:
            return nil
        default:
            return ["Accept":"application/json"]
        }
    }

    public var validationType: ValidationType {
        return .none
    }
}
private let defaultDownloadDestination: DownloadDestination = { temporaryURL, response in
    let directoryURLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    if !directoryURLs.isEmpty {
        guard let suggestedFilename = response.suggestedFilename else {
            fatalError("@Moya/contributor error!! We didn't anticipate this being nil")
        }
        return (directoryURLs[0].appendingPathComponent(suggestedFilename), [])
    }
    
    return (temporaryURL, [])
}
