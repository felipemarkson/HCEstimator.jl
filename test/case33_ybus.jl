function get_ybus()
    #from matpower
    ybus = [
        (1379.7974868010331, -703.36748339344058), (-1379.7974868010326, 703.36748339344058), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.),
        (-1379.7974868010326, 703.36748339344058), (2149.4368630632848, -1322.9549474641478), (-258.13726441720388, 131.47721535006858), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (-511.5021118450482, 488.11024872063865), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.),
        (0., 0.), (-258.13726441720388, 131.47721535006858), (848.01838235020819, -474.03325448190787), (-347.72101776801628, 177.09070415433175), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (-242.16010016498808, 165.46533497750752), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.),
        (0., 0.), (0., 0.), (-347.72101776801628, 177.09070415433175), (681.65768847345453, -347.16970678365755), (-333.93667070543819, 170.0790026293258), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.),
        (0., 0.), (0., 0.), (0., 0.), (-333.93667070543819, 170.0790026293258), (446.07112747825659, -266.87883289493993), (-112.13445677281842, 96.799830265614105), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.),
        (0., 0.), (0., 0.), (0., 0.), (0., 0.), (-112.13445677281842, 96.799830265614105), (810.81081225833236, -653.40580767389326), (-71.786265476224997, 237.29348896482884), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (-626.89009000928888, 319.31248844345026), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.),
        (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (-71.786265476224997, 237.29348896482884), (274.89952940823412, -304.41736901807127), (-203.11326393200912, 67.123880053242416), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.),
        (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (-203.11326393200912, 67.123880053242416), (305.74544791639141, -140.85962398591522), (-102.63218398438232, 73.735743932672818), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.),
        (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (-102.63218398438232, 73.735743932672818), (204.81480857639477, -146.16404115885513), (-102.18262459201244, 72.428297226182309), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.),
        (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (-102.18262459201244, 72.428297226182309), (837.08726489889182, -315.40287284421652), (-734.9046403068794, 242.97457561803418), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.),
        (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (-734.9046403068794, 242.97457561803418), (1120.7984670263254, -370.57515184861893), (-385.89382671944588, 127.60057623058476), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.),
        (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (-385.89382671944588, 127.60057623058476), (453.3289876750257, -180.65753184311802), (-67.435160955579832, 53.056955612533272), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.),
        (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (-67.435160955579832, 53.056955612533272), (175.73097555203762, -195.60512077779214), (-108.29581459645779, 142.54816516525887), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.),
        (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (-108.29581459645779, 142.54816516525887), (259.62071319261491, -277.22988532565626), (-151.32489859615711, 134.68172016039742), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.),
        (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (-151.32489859615711, 134.68172016039742), (291.38961111396929, -236.96668363147336), (-140.06471251781215, 102.28496347107594), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.),
        (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (-140.06471251781215, 102.28496347107594), (184.74978127162765, -161.94594345980323), (-44.6850687538155, 59.660979988727298), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.),
        (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (-44.6850687538155, 59.660979988727298), (180.27011341680137, -165.98040041865715), (-135.58504466298587, 106.31942042992985), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.),
        (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (-135.58504466298587, 106.31942042992985), (135.58504466298587, -105.91942042992984), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.),
        (0., 0.), (-511.5021118450482, 488.11024872063865), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (570.30762971538297, -541.09854742765776), (-58.80551787033481, 52.988298707019162), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.),
        (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (-58.80551787033481, 52.988298707019162), (224.31234207269267, -246.34230257074509), (-165.50682420235785, 193.35400386372592), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.),
        (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (-165.50682420235785, 193.35400386372592), (247.7758849428638, -302.12927632370901), (-82.269060740505935, 108.77527245998309), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.),
        (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (-82.269060740505935, 108.77527245998309), (82.269060740505935, -108.77527245998309), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.),
        (0., 0.), (0., 0.), (-242.16010016498808, 165.46533497750752), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (352.09329719985436, -252.27338621838055), (-109.9331970348663, 86.808051240873013), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.),
        (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (-109.9331970348663, 86.808051240873013), (220.88165581050799, -173.62274367261969), (-110.9484587756417, 86.814692431746678), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.),
        (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (-110.9484587756417, 86.814692431746678), (110.9484587756417, -86.814692431746678), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.),
        (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (-626.89009000928888, 319.31248844345026), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (1074.7451893356217, -547.33723477801823), (-447.85509932633283, 228.02474633456791), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.),
        (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (-447.85509932633283, 228.02474633456791), (533.00728178818952, -303.10179328873727), (-85.152182461856654, 75.077046954169361), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.),
        (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (-85.152182461856654, 75.077046954169361), (198.45750094642182, -173.78595780940725), (-113.30531848456518, 98.708910855237903), (0., 0.), (0., 0.), (0., 0.), (0., 0.),
        (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (-113.30531848456518, 98.708910855237903), (364.06135511406887, -226.43390675676198), (-250.75603662950371, 127.72499590152407), (0., 0.), (0., 0.), (0., 0.),
        (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (-250.75603662950371, 127.72499590152407), (333.96709674337552, -209.96252764209243), (-83.21106011387181, 82.237531740568343), (0., 0.), (0., 0.),
        (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (-83.21106011387181, 82.237531740568343), (302.0744900671599, -337.3314942678345), (-218.86342995328809, 255.09396252726617), (0., 0.),
        (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (-218.86342995328809, 255.09396252726617), (356.39472533686063, -468.93294478625774), (-137.53129538357254, 213.83898225899159),
        (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (0., 0.), (-137.53129538357254, 213.83898225899159), (137.53129538357254, -213.2389822589916)
    ]

    Ybus = zeros(Complex, 33, 33)
    k = 1
    for i in 1:33
        for j in 1:33
            real = ybus[k][1]
            img = ybus[k][2]
            Ybus[i, j] = real + img * 1im
            k = k + 1
        end
    end
    return Ybus
end