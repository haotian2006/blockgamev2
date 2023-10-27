local Handler = {}
function Handler.error(errormsg)
    error(errormsg)
end
function Handler.warn(msg)
    warn(msg)
end
_G.error = Handler.error
_G.warn = Handler.warn
return Handler