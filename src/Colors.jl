const _yaml_colors = YAML.load_file(joinpath(@__DIR__, "colors.yaml"))

function yaml_color(name::AbstractString, shade::AbstractString = "base")
    parse(Colorant, _yaml_colors[name][shade])
end

const cornflowerblue = yaml_color("cornflowerblue")
const cornflowerblue_light = yaml_color("cornflowerblue", "light")
const cornflowerblue_dark = yaml_color("cornflowerblue", "dark")
export cornflowerblue, cornflowerblue_light, cornflowerblue_dark

const crimson = yaml_color("crimson")
const crimson_light = yaml_color("crimson", "light")
const crimson_dark = yaml_color("crimson", "dark")
export crimson, crimson_light, crimson_dark

const cucumber = yaml_color("cucumber")
const cucumber_light = yaml_color("cucumber", "light")
const cucumber_dark = yaml_color("cucumber", "dark")
export cucumber, cucumber_light, cucumber_dark

const california = yaml_color("california")
const california_light = yaml_color("california", "light")
const california_dark = yaml_color("california", "dark")
export california, california_light, california_dark

const juliapurple = yaml_color("juliapurple")
const juliapurple_light = yaml_color("juliapurple", "light")
const juliapurple_dark = yaml_color("juliapurple", "dark")
export juliapurple, juliapurple_light, juliapurple_dark

const greyseas = yaml_color("greyseas")
const greyseas_light = yaml_color("greyseas", "light")
const greyseas_dark = yaml_color("greyseas", "dark")
export greyseas, greyseas_light, greyseas_dark

const darkbg = yaml_color("darkbg")
const darkbg_light = yaml_color("darkbg", "light")
const darkbg_dark = yaml_color("darkbg", "dark")
export darkbg, darkbg_light, darkbg_dark

__crimson = brighten(crimson, 0.1)
__california = darken(california, 0.1)

const epipelagic = colorant"#FA9F42"
export epipelagic
const mesopelagic = colorant"#007878"
export mesopelagic
const bathypelagic = colorant"#023653"
export bathypelagic
const abyssopelagic = colorant"#280137"
export abyssopelagic

function perceived_lightness(c::AbstractRGB)
    # ? https://stackoverflow.com/questions/596216/formula-to-determine-perceived-brightness-of-rgb-color
    r, g, b = c.r, c.g, c.b
    lin(c) = c ≤ 0.04045 ? c / 12.92 : ((c + 0.055) / 1.055)^2.4
    Y = 0.2126lin(r) + 0.7152lin(g) + 0.0722lin(b)
    return Y ≤ (216 / 24389) ? Y * (24389 / 27) : 116 * Y^(1 / 3) - 16
end
export perceived_lightness

function make_lightness_linear(cs; flat = false, tol = 0.001)
    ls = perceived_lightness.(RGB.(cs))
    if flat
        mb = [mean(ls), 0] # Constant brightness
    else
        mb = [ones(length(ls)) (1:length(ls))] \ ls
    end
    L = mb[1] .+ mb[2] * (1:length(ls)) |> collect
    map(enumerate(cs)) do (i, c)
        l = L[i]
        while abs(l - perceived_lightness(c)) > tol &&
            perceived_lightness(c) ∈ 0.1 .. 99.9
            if perceived_lightness(c) > l
                c = darken(c, tol)
            else
                c = brighten(c, tol)
            end
        end
        return c
    end
end
export make_lightness_linear

pelagic = cgrad([epipelagic, mesopelagic, bathypelagic, abyssopelagic],
                [0, 0.35, 0.6, 0.78, 1]) #.|> RGB #|> make_lightness_linear |> cgrad
export pelagic

C = reverse(cgrad([__crimson, juliapurple, cornflowerblue], [0, 0.65, 1]))
export sunset

C = cgrad([__crimson, __california, cucumber, cornflowerblue],
          [0.25, 0.4, 0.6, 0.8]) |> reverse
export sunrise

C = cgrad([california, __crimson, cornflowerblue, cucumber, __california],
          [0, 0.2, 0.5, 0.8, 1])
export cyclicsunrise

const cyclic = cgrad([darkbg, __crimson, greyseas, cornflowerblue, darkbg],
                     [0, 0.25, 0.5, 0.7, 1])
# C = EqualizeColorMap("RGB", C[0:0.001:1], "CIEDE2000", [1, 1, 1], 6, true)
# const cyclic = cgrad([RGB(c...) for c in eachrow(C)])
export cyclic

const lightsunset = cgrad([crimson, greyseas, cornflowerblue], [0, 0.5, 1])
export lightsunset

const darksunset = cgrad([__crimson, darkbg, cornflowerblue], [0, 0.5, 1])
export darksunset

const binarysunset = cgrad([darkbg, __crimson, cornflowerblue, greyseas],
                           [0, 0.25, 0.5, 0.7, 1])
export binarysunset

const sunset = cgrad([__crimson, juliapurple, cornflowerblue], [0, 0.65, 1])
# C = EqualizeColorMap("RGB", C[0:0.001:1], "CIEDE2000", [1, 1, 1], 6)
# const sunset = cgrad([RGB(c...) for c in eachrow(C)])
export sunset

const sunrise = cgrad([__crimson, __california, cucumber, cornflowerblue],
                      [0.25, 0.4, 0.6, 0.75])
# C = EqualizeColorMap("RGB", C[0:0.001:1], "CIEDE2000", [1, 1, 1], 6)
# const sunrise = cgrad([RGB(c...) for c in eachrow(C)])
export sunrise

const cyclicsunrise = cgrad([
                                __california,
                                __crimson,
                                cornflowerblue,
                                cucumber,
                                __california
                            ],
                            [0, 0.2, 0.5, 0.8, 1])
# C = EqualizeColorMap("RGB", C[0:0.001:1], "CIEDE2000", [1, 1, 1], 6, true)
# const cyclicsunrise = cgrad([RGB(c...) for c in eachrow(C)])
export cyclicsunrise

const foresight_colormaps = Dict(:sunset => sunset,
                                 :sunrise => sunrise,
                                 :cyclicsunrise => cyclicsunrise,
                                 :cyclic => cyclic,
                                 :lightsunset => lightsunset,
                                 :darksunset => darksunset,
                                 :binarysunset => binarysunset,
                                 :pelagic => pelagic)
