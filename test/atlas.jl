@testset "AtlasSLProgram" begin
    for s0 in ["", "\n# comment\n \n # comment  \n\n # comment"]
        p0 = AtlasSLProgram(s0)
        @test p0.code == s0
        @test p0.ngens == 2
        @test isempty(p0.lines)
        @test p0.outputs == 1:2
    end

    s1 = " inp 3 3 1  2 \n oup 2 2  2"
    p1 = AtlasSLProgram(s1)
    @test p1.code == s1
    @test p1.ngens == 3
    @test isempty(p1.lines)
    @test p1.outputs == [3, 3]

    p2 = AtlasSLProgram("inp 2 \n inp 1 4 \n oup 3 4 1 2")
    @test p2.ngens == 3
    @test p2.outputs == [3, 1, 2]

    p3 = AtlasSLProgram("oup 1 2")
    @test p3.ngens == 2
    @test p3.outputs == [2]

    @test_throws ArgumentError AtlasSLProgram("inp 1 2") # implicit "oup 1 2"

    p4 = AtlasSLProgram("inp 1 2 \n oup 2 2 2")
    @test p4.ngens == 1
    @test p4.outputs == [1, 1]

    for bad in ["inp 1 2", "oup 3", "oup 2 \n inp 2",
                "inp 2 \n inp 1", "oup 2 \n oup 1",
                "inp 2 1 2 3", "oup 2 1",
                "inp 3 \n oup 4", "oup 2 2 3",
                "mu 1 2 3 \n inp 3", "oup 2 \n mu 1 2 3"]
        @test_throws ArgumentError AtlasSLProgram(bad)
    end

    for bad in ["cjr 1", "cjr 1 2 3",
                "cj 1 2", "cj 1 2 3 4",
                "com 1 2", "com 1 2 3 4",
                "mu 1 2", "mu 1 2 3 4",
                "pwr 1 2", "pwr 1 2 3 4",
                "iv 1", "iv 1 2 3",
                "cp 1", "cp 1 2 3"]
        @test_throws ArgumentError AtlasSLProgram(bad)
    end
    q1 = AtlasSLProgram("""
           cjr 1 2
           cj 1 2 3
           com 2 3 4
           mu 3 4 5
           pwr 4 5 6
           iv 6 7
           cp 7 8
           oup 3 6 7 8
         """)
    @test q1.ngens == 2
    @test q1.outputs == [6, 7, 8]
    @test q1.lines == [AtlasLine(:cj, 1, 1, 2),
                       AtlasLine(:cj, 3, 1, 2),
                       AtlasLine(:com, 4, 2, 3),
                       AtlasLine(:mu, 5, 3, 4),
                       AtlasLine(:pwr, 6, 4, 5),
                       AtlasLine(:iv, 7, 6),
                       AtlasLine(:cp, 8, 7)
                       ]
    @test_throws ArgumentError AtlasSLProgram("unknown 1 2")
end
