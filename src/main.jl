using Pkg
Pkg.activate(".")
using HTTP
using JSON2
using Parameters

@with_kw mutable struct tokenReq
    token::String = ""
end

function home(req::HTTP.Request)
    @info "Request has hit"
    return HTTP.Response(200, JSON2.write(Dict("response" => "Hello from Auth service endpoint")))
end

function authHandler(req::HTTP.Request)
    payld = JSON2.read(IOBuffer(HTTP.payload(req)), tokenReq)
    token = payld.token
    @info token
    if (token == "abcdef")
      res = HTTP.Response(200, "Valid Token: $token")
    else 
      res = HTTP.Response(403, "Invalid Token: $token")
    end
    return res
end

function newAuthHandler(req::HTTP.Request)
  token = HTTP.header(req, "token")
  @info "Token Received: $token"
  if (token == "abcdef")
    res = HTTP.Response(200, "Valid Token: $token")
  else 
    res = HTTP.Response(403, "Invalid Token: $token")
  end
  return res
end

Router = HTTP.Router()
HTTP.@register(Router, "GET",  "/", newAuthHandler)
HTTP.serve(Router, "0.0.0.0", 8088)
