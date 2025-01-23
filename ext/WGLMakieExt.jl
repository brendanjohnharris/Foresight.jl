module WGLMakieExt
using WGLMakie
using WGLMakie.Bonito
using Foresight

# function saveit(file = "index.html", f)
#     open(file, "w") do io
#         println(io, """
#         <html>
#             <head>
#             </head>
#             <body>
#         """)
#         Page(exportable = true, offline = true)
#         app = App() do
#             DOM.div(f)
#         end
#         show(io, MIME"text/html"(), app)
#         # or anything else from Bonito, or that can be displayed as html:
#         println(io, """
#             </body>
#         </html>
#         """)
#     end
# end

end # module
