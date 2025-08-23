---
layout: post
title: My Awesome Code
date: February 25th, 2025
---

{% highlight cpp %}
    #include <iostream>
    #include <sstream>
    #include "HttpParser.h"

    network::HttpMessage::HttpMessage(std::string version, std::map<std::string, std::string> headers, std::string body){
        m_version = version;
        m_headers = headers;
        m_body = body;
    }

    network::HttpMessage::HttpMessage(std::string raw)
    {
        std::istringstream lines (raw);

        // Request Line
        std::string request_line;
        std::getline(lines, request_line);
        m_version = request_line.substr(raw.find("HTTP/")+5, 3);

        // Header
        std::string line;
        while(std::getline(lines, line) && line.find(": ") != std::string::npos){
            std::size_t delimiter = line.find(": ");
            std::string key = line.substr(0, delimiter);
            std::string value = line.substr(delimiter + 2, line.find("\n", delimiter));
            m_headers.emplace(key, value);
        }

        // Body
        while(std::getline(lines, line)){
            m_body += line;
        }
    }

    const std::string& network::HttpMessage::getVersion()
    {
        return m_version;
    }
    const std::map<std::string, std::string>& network::HttpMessage::getHeaders()
    {
        return m_headers;
    }
    const std::string& network::HttpMessage::getBody()
    {
        return m_body;
    }

    void network::HttpMessage::setVersion(std::string version)
    {
        m_version = version;
    }
    void network::HttpMessage::setHeader(std::string key, std::string value)
    {
        m_headers.insert_or_assign(key, value);
    }
    void network::HttpMessage::setBody(std::string body)
    {
        m_body = body;
    }

    std::string network::HttpMessage::headersAsString()
    {
        std::string out;
        for(auto& key_value : m_headers){
            out += key_value.first + ": " + key_value.second + "\n";
        }
        return out;
    }

    network::HttpResponse::HttpResponse(int status_code, std::string status_text, std::string version, std::map<std::string, std::string> headers, std::string body)
        : HttpMessage(version, headers, body)
    {
        m_status_code = status_code;
        m_status_text = status_text;
    }
    network::HttpResponse::HttpResponse(std::string raw): network::HttpMessage(raw)
    {
        int first_space = raw.find(" ");
        int second_space = raw.find(" ", first_space+1);
        m_status_code = std::stoi(raw.substr(first_space+1, 3));
        m_status_text = raw.substr(second_space + 1, raw.find("\n") - second_space - 1);
    }

    int network::HttpResponse::getStatusCode()
    {
        return m_status_code;
    }
    const std::string& network::HttpResponse::getStatusText()
    {
        return m_status_text;
    }
    void network::HttpResponse::setStatusCode(int status_code)
    {
        m_status_code = status_code;
    }
    void network::HttpResponse::setStatusText(std::string status_text)
    {
        m_status_text = status_text;
    }
    std::string network::HttpResponse::asString()
    {
        return "HTTP/" + m_version + " " + std::to_string(m_status_code) + " " + m_status_text + "\n" + headersAsString() + "\n" + m_body;
    }


    network::HttpRequest::HttpRequest(Method method, std::string path, std::string version, std::map<std::string, std::string> headers, std::string body)
        : HttpMessage(version, headers, body)
    {
        m_method = method;
        m_path = path;
    }
    network::HttpRequest::HttpRequest(std::string raw): network::HttpMessage(raw)
    {
        std::string request_line = raw.substr(0, raw.find("\n"));
        if(request_line.rfind("GET",0) == 0){
            m_method = Method::GET;
        }else if(request_line.rfind("POST",0) == 0){
            m_method = Method::POST;
        }else if(request_line.rfind("PUT",0) == 0){
            m_method = Method::PUT;
        }else if(request_line.rfind("PATCH",0) == 0){
            m_method = Method::PATCH;
        }else if(request_line.rfind("DELETE",0) == 0){
            m_method = Method::DELETE;
        }

        m_path = raw.substr(raw.find("/"), raw.find("HTTP/") - raw.find("/") - 1);
    }

    network::HttpRequest::Method network::HttpRequest::getMethod()
    {
        return m_method;
    }

    const std::string& network::HttpRequest::getPath()
    {
        return m_path;
    }

    void network::HttpRequest::setMethod(network::HttpRequest::Method method)
    {
        m_method = method;
    }

    void network::HttpRequest::setPath(std::string path)
    {
        m_path = path;
    }

    std::string network::HttpRequest::methodAsString()
    {
        std::string methodName;
        switch (m_method)
        {
            case network::HttpRequest::Method::GET:     methodName = "GET";     break;
            case network::HttpRequest::Method::POST:    methodName = "POST";    break;
            case network::HttpRequest::Method::PATCH:   methodName = "PATCH";   break;
            case network::HttpRequest::Method::PUT:     methodName = "PUT";     break;
            case network::HttpRequest::Method::DELETE:  methodName = "DELETE";  break;
        }
        return methodName;
    }

    std::string network::HttpRequest::asString()
    {
        return methodAsString() + " " + m_path + " HTTP/" + m_version + "\n" + headersAsString() + "\n" + m_body;
    }
{% endhighlight %}
