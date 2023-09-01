//
//  KAlamofire.swift
//  KNetwork
//
//  Created by yong ding on 2022/6/17.
//

import Foundation
import Alamofire

@objc public class KAlamofire: NSObject {

    @objc public static let NET_CODE_SUCCESS = 0
    @objc public static let NET_CODE_FAIL = -1

    //一些映射值
    private static let METHOD:[String:HTTPMethod] = ["get":.get, "post":.post, "delete":.delete, "put":.put]
    private static let ENCODING:[String:ParameterEncoding] = ["default":URLEncoding.default,
                                                              "httpBody":URLEncoding.httpBody,
                                                              "json":JSONEncoding.default,
                                                              "queryString":URLEncoding.queryString]
    private var idDebug: Bool = true
    private var method: HTTPMethod = .get
    private var parameters: Parameters? = nil
    private var encoding: ParameterEncoding = URLEncoding.default
    private var headers: HTTPHeaders = [String: String]()

    @objc public override init() {}

    /**
     * 设置debug模式，默认为debug模式，debug模式下会打印日志
     */
    @objc public func with(debug: Bool) -> KAlamofire {
        self.idDebug = debug
        return self
    }

    /**
     * 设置网络请求方式
     * @params method 请求方式，如get，post，delete等
     */
    @objc public func with(method: String) -> KAlamofire {
        if let mapValue = KAlamofire.METHOD[method] {
            self.method = mapValue
        }
        return self
    }

    /**
     * 设置请求参数
     * @params parameter 请求参数，字典类型
     */
    @objc public func with(parameter: [String: Any]?) -> KAlamofire {
        self.parameters = parameter
        return self
    }

    /**
     * 设置编码方式
     * @parameter 具体的编码方式，具体参考：ENCODING
     */
    @objc public func with(encoding: String) -> KAlamofire {
        if let mapValue = KAlamofire.ENCODING[encoding] {
            self.encoding = mapValue
        }
        return self
    }

    /**
     * 请求头数据
     *  @params header 具体的请求头，字典类型
     */
    @objc public func with(header: [String: String]) -> KAlamofire {
        self.headers = header
        return self
    }

    /**
     * 单独设置header数据
     * @params key 要设置的箭
     * @params value 箭对应的值
     */
    @objc public func setHeaderParam(key: String, value: String) -> KAlamofire {
        self.headers[key] = value
        return self
    }

    /**
     * 请求网络
     * @params url 请求链接，如果是完整链接（以http开头的链接），将直接请求；如果path（如“/cgi/test”），将拼接host在前面
     * @params inet 请求回调，格式(ret_code, ret_msg)
     */
    @objc public func start(url: String, inet: @escaping ((Int, [String : [String]], String) -> Void)) {
        self.req(rurl: url, rinet: { (retCode: Int, header: [String: [String]], rdata: Data?) in
            if rdata != nil {
                inet(retCode, header, String(data: rdata!, encoding: .utf8)!)
            } else {
                inet(retCode, header, "unknown error")
            }
        })
    }

    /**
     * 请求网络，回调data
     * @params url 请求链接，如果是完整链接（以http开头的链接），将直接请求；如果path（如“/cgi/test”），将拼接host在前面
     * @params inet 请求回调，格式(ret_code, ret_msg)
     */
    @objc public func req(rurl: String, rinet: @escaping ((Int, [String : [String]], Data?) -> Void)) {
        Alamofire.request(rurl,
                        method: method,
                        parameters: parameters,
                        encoding: encoding,
                        headers: headers)
                .response(queue: DispatchQueue.main) {response in
                    var resHeader: [String : [String]] = [String : [String]]()
                    if let data = response.data {
                        for e in response.response?.allHeaderFields ?? [AnyHashable: Any]() {
                            resHeader[e.key as! String] =  ["\(e.value)"]
                        }
                        if self.idDebug {
                            print(
                                    "http ===> \(rurl)\n" +
                                            "header: \(self.headers)\n" +
                                            "parameter: \(self.parameters)\n" +
                                            "method: \(self.method)\n" +
                                            "<=== resHeader: \(resHeader)"
                            )
                        }
                        rinet(KAlamofire.NET_CODE_SUCCESS, resHeader, data)
                    } else if let err = response.error {
                        let errData = "\(err.localizedDescription)".data(using: .utf8)
                        rinet(KAlamofire.NET_CODE_FAIL, resHeader, errData)
                    } else {
                        rinet(KAlamofire.NET_CODE_FAIL, resHeader, "unknown error".data(using: .utf8))
                    }
                }
    }

    @objc public func delanTest(ok: String) {
        print("this is my test")
    }

}
