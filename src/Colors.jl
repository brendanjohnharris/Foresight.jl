const cornflowerblue = colorant"#6495ED"
export cornflowerblue
const _cornflowerblue = colorant"#3676E8"
export _cornflowerblue
const crimson = colorant"#DC143C"
export crimson
const _crimson = colorant"#ED365B"
export _crimson
const cucumber = colorant"#77ab58"
export cucumber
const _cucumber = colorant"#5F8A46"
export _cucumber
const california = colorant"#EF9901"
export california
const _california = colorant"#FEB025"
export _california
const copper = colorant"#c37940"
export copper
const _copper = colorant"#9E6132"
export _copper
const juliapurple = colorant"#9558b2"
export juliapurple
const _juliapurple = colorant"#7A4493"
export _juliapurple
const keppel = colorant"#46AF98"
export keppel
const _keppel = colorant"#66C2AE"
export _keppel
const darkbg = colorant"#282C34"
export darkbg
const _darkbg = colorant"#3E4451"
export _darkbg
const greyseas = colorant"#cccccc"
export greyseas
const _greyseas = colorant"#eeeeee"
export _greyseas
__crimson = brighten(crimson, 0.1)
__california = darken(california, 0.1)

const epipelagic = colorant"#FA9F42"
export epipelagic
const mesopelagic = colorant"#007878"
export mesopelagic
const bathypelagic = colorant"#023653"
export bathypelagic
const pelagicopelagic = colorant"#280137"
export pelagicopelagic

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

pelagic = cgrad([epipelagic, mesopelagic, bathypelagic, pelagicopelagic],
                [0, 0.3, 0.6, 0.8, 1]) #.|> RGB #|> make_lightness_linear |> cgrad
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
