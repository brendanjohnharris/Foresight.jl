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

C = reverse(cgrad([crimson, juliapurple, cornflowerblue], [0, 0.65, 1]))
export sunset

C = cgrad([crimson, california, cucumber, cornflowerblue], [0.2, 0.4, 0.6, 0.8])
export sunrise

C = cgrad([california, crimson, cornflowerblue, cucumber, california],
          [0, 0.2, 0.5, 0.8, 1])
export cyclicsunrise

const cyclic = cgrad([darkbg, crimson, greyseas, cornflowerblue, darkbg],
                     [0, 0.25, 0.5, 0.7, 1])
# C = EqualizeColorMap("RGB", C[0:0.001:1], "CIEDE2000", [1, 1, 1], 6, true)
# const cyclic = cgrad([RGB(c...) for c in eachrow(C)])
export cyclic

const lightsunset = reverse(cgrad([crimson, greyseas, cornflowerblue], [0, 0.5, 1]))
export lightsunset

const darksunset = reverse(cgrad([crimson, darkbg, cornflowerblue], [0, 0.5, 1]))
export darksunset

const sunset = reverse(cgrad([crimson, juliapurple, cornflowerblue], [0, 0.65, 1]))
# C = EqualizeColorMap("RGB", C[0:0.001:1], "CIEDE2000", [1, 1, 1], 6)
# const sunset = cgrad([RGB(c...) for c in eachrow(C)])
export sunset

const sunrise = cgrad([crimson, california, cucumber, cornflowerblue], [0.2, 0.4, 0.6, 0.8])
# C = EqualizeColorMap("RGB", C[0:0.001:1], "CIEDE2000", [1, 1, 1], 6)
# const sunrise = cgrad([RGB(c...) for c in eachrow(C)])
export sunrise

const cyclicsunrise = cgrad([california, crimson, cornflowerblue, cucumber, california],
                            [0, 0.2, 0.5, 0.8, 1])
# C = EqualizeColorMap("RGB", C[0:0.001:1], "CIEDE2000", [1, 1, 1], 6, true)
# const cyclicsunrise = cgrad([RGB(c...) for c in eachrow(C)])
export cyclicsunrise
