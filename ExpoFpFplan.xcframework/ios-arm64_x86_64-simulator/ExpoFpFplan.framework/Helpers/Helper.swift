import Foundation
import WebKit

public struct Helper{
    
    public static func isValidUrl(_ url: String) -> Bool {
        if(url == nil || url.isEmpty || url.starts(with: "http://")){
            return false
        }
        
        var formatUrl = (url.starts(with: "https://") ? url : "https://\(url)")
        let regex = try! NSRegularExpression(pattern: "https://.+\\.expofp\\.com.*")
        let range = NSRange(location: 0, length: formatUrl.utf16.count)
        let result = regex.firstMatch(in: formatUrl, options: [], range: range) != nil
        return result
    }
    
    public static func getEventAddress(_ url: String) -> String {
        func getWithoutParams (_ url: String, _ delimiter: Character) -> String {
            if let sIndex = url.firstIndex(of: delimiter){
                return String(url[...url.index(before: sIndex)])
            }
            else{
                return url
            }
        }
        
        let mainPart = url.replacingOccurrences(of: "https://www.", with: "")
            .replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "http://www.", with: "")
            .replacingOccurrences(of: "http://", with: "")
        
        let result = getWithoutParams(getWithoutParams(mainPart, "/"), "?")
        return result
    }
    
    public static func getParams(_ url: String) -> String {
        if let index = url.firstIndex(of: "?") {
            return String(url[index...])
        }
        else{
            return ""
        }
    }
    
    public static func getEventId(_ url: String) -> String {
        let eventAddress = getEventAddress(url)
        if let index = eventAddress.firstIndex(of: ".") {
            return String(eventAddress[...eventAddress.index(index, offsetBy: -1)])
        }
        else{
            return ""
        }
    }
    
    public static func saveConfiguration(_ configuration: Configuration, fplanConfigPath: URL) throws {
        let fileDirectory = fplanConfigPath.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: fileDirectory.path){
            try! FileManager.default.createDirectory(atPath: fileDirectory.path, withIntermediateDirectories: true, attributes: nil)
        }
        
        let jsonEncoder = JSONEncoder()
        
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        jsonEncoder.dateEncodingStrategy = .custom({ date, encoder in
            var singleValueEnc = encoder.singleValueContainer()
            try singleValueEnc.encode(formatter.string(from: date))
        })
        
        let jsonData = try jsonEncoder.encode(configuration)
        let configJson = String(data: jsonData, encoding: String.Encoding.utf8)
        
        try configJson!.write(to: fplanConfigPath, atomically: true, encoding: String.Encoding.utf8)
    }
    
    public static func parseConfigurationJson(_ json: Data) throws -> Configuration {
        let decoder = JSONDecoder()
        
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            if let date = formatter.date(from: dateStr) {
                return date
            }
            
            throw DateError.invalidDate
        })
        
        let config = try decoder.decode(Configuration.self, from: json)
        return config
    }
    
    public static func downloadFile(_ url: URL, _ filePath: URL){
        let fileDirectory = filePath.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: fileDirectory.path){
            try! FileManager.default.createDirectory(atPath: fileDirectory.path, withIntermediateDirectories: true, attributes: nil)
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: url, completionHandler: { data, response, error in
            if(error == nil) {
                let fileManager = FileManager.default
                fileManager.createFile(atPath: filePath.path, contents: data)
            }
        })
        task.resume()
    }
    
    public static func loadConfiguration(fplanConfigPath: URL) throws -> Configuration {
        let json = try String.init(contentsOf: fplanConfigPath)
        return try parseConfigurationJson(json.data(using: .utf8)!)
    }
    
    public static func loadConfiguration(_ configuration: Configuration?, fplanConfigUrl: URL, callback: @escaping ((_ configuration: Configuration) -> Void)) {
        /*if(configuration != nil){
            callback(configuration!)
        }*/
        
        let session = URLSession.shared
        let task = session.dataTask(with: fplanConfigUrl, completionHandler: { data, response, error in
            
            if let json = data {
                guard let config = try? parseConfigurationJson(json) else {
                    print("[Fplan] Config file loaded from assets")
                    let config = configuration ?? getDefaultConfiguration()
                    callback(config)
                    return
                }
                
                print("[Fplan] Config file loaded from \(fplanConfigUrl.absoluteString)")
                callback(config)
            }
            else {
                print("[Fplan] Config file loaded from assets")
                let config = configuration ?? getDefaultConfiguration()
                callback(config)
            }
            
            
        })
        task.resume()
    }
    
    public static func getDefaultConfiguration() -> Configuration {
        return Configuration(androidHtmlUrl: nil, iosHtmlUrl: nil, zipArchiveUrl: nil, enablePositioningAfter: nil, disablePositioningAfter: nil)
    }
    
    public static func getCacheDirectory() -> URL {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    public static func getAllowConsentParametr(string: String, settings: Settings) -> String{
        return string.lowercased().contains("allowconsent=") ? "" : (string.contains("?") ? "&" : "?") + "allowConsent=\(settings.allowConsent)"
    }
    
    public static func getLoadingPageHtml() -> String {
        return
    """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, width=device-width" />
        <style>
          html,
          body {
            touch-action: none;
            margin: 0;
            padding: 0;
            height: 100%;
            width: 100%;
            background: #ebebeb;
            position: fixed;
            overflow: hidden;
          }
          @media (max-width: 820px) and (min-width: 500px) {
            html {
              font-size: 13px;
            }
          }
        </style>
        <style>
          .lds-grid {
            top: 42vh;
            margin: 0 auto;
            display: block;
            position: relative;
            width: 64px;
            height: 64px;
          }
    
          .lds-grid div {
            position: absolute;
            width: 13px;
            height: 13px;
            background: #aaa;
            border-radius: 50%;
            animation: lds-grid 1.2s linear infinite;
          }
    
          .lds-grid div:nth-child(1) {
            top: 6px;
            left: 6px;
            animation-delay: 0s;
          }
    
          .lds-grid div:nth-child(2) {
            top: 6px;
            left: 26px;
            animation-delay: -0.4s;
          }
    
          .lds-grid div:nth-child(3) {
            top: 6px;
            left: 45px;
            animation-delay: -0.8s;
          }
    
          .lds-grid div:nth-child(4) {
            top: 26px;
            left: 6px;
            animation-delay: -0.4s;
          }
    
          .lds-grid div:nth-child(5) {
            top: 26px;
            left: 26px;
            animation-delay: -0.8s;
          }
    
          .lds-grid div:nth-child(6) {
            top: 26px;
            left: 45px;
            animation-delay: -1.2s;
          }
    
          .lds-grid div:nth-child(7) {
            top: 45px;
            left: 6px;
            animation-delay: -0.8s;
          }
    
          .lds-grid div:nth-child(8) {
            top: 45px;
            left: 26px;
            animation-delay: -1.2s;
          }
    
          .lds-grid div:nth-child(9) {
            top: 45px;
            left: 45px;
            animation-delay: -1.6s;
          }
    
          @keyframes lds-grid {
            0%,
            100% {
              opacity: 1;
            }
    
            50% {
              opacity: 0.5;
            }
          }
        </style>
    </head>
    <body>
    <div id="floorplan">
        <div class="lds-grid">
            <div></div>
            <div></div>
            <div></div>
            <div></div>
            <div></div>
            <div></div>
            <div></div>
            <div></div>
            <div></div>
        </div>
    </div>
    </body>
    </html>
    """;
    }
}

