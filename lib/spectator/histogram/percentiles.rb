module Spectator
  # Module for percentile approximations
  module Histogram
    require 'spectator/meter_id'

    # Internal helper class used by PercentileTimer and
    # PercentileDistributionSummary to help with generating and using
    # buckets for percentile approximations

    # rubocop: disable Metrics/ClassLength
    class PercentileBuckets
      # rubocop:enable Metrics/ClassLength
      MAX_VALUE = 9_223_372_036_854_775_807

      @bucket_values = [
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        10,
        11,
        12,
        13,
        14,
        16,
        21,
        26,
        31,
        36,
        41,
        46,
        51,
        56,
        64,
        85,
        106,
        127,
        148,
        169,
        190,
        211,
        232,
        256,
        341,
        426,
        511,
        596,
        681,
        766,
        851,
        936,
        1024,
        1365,
        1706,
        2047,
        2388,
        2729,
        3070,
        3411,
        3752,
        4096,
        5461,
        6826,
        8191,
        9556,
        10_921,
        12_286,
        13_651,
        15_016,
        16_384,
        21_845,
        27_306,
        32_767,
        38_228,
        43_689,
        49_150,
        54_611,
        60_072,
        65_536,
        87_381,
        109_226,
        131_071,
        152_916,
        174_761,
        196_606,
        218_451,
        240_296,
        262_144,
        349_525,
        436_906,
        524_287,
        611_668,
        699_049,
        786_430,
        873_811,
        961_192,
        1_048_576,
        1_398_101,
        1_747_626,
        2_097_151,
        2_446_676,
        2_796_201,
        3_145_726,
        3_495_251,
        3_844_776,
        4_194_304,
        5_592_405,
        6_990_506,
        8_388_607,
        9_786_708,
        11_184_809,
        12_582_910,
        13_981_011,
        15_379_112,
        16_777_216,
        22_369_621,
        27_962_026,
        33_554_431,
        39_146_836,
        44_739_241,
        50_331_646,
        55_924_051,
        61_516_456,
        67_108_864,
        89_478_485,
        111_848_106,
        134_217_727,
        156_587_348,
        178_956_969,
        201_326_590,
        223_696_211,
        246_065_832,
        268_435_456,
        357_913_941,
        447_392_426,
        536_870_911,
        626_349_396,
        715_827_881,
        805_306_366,
        894_784_851,
        984_263_336,
        1_073_741_824,
        1_431_655_765,
        1_789_569_706,
        2_147_483_647,
        2_505_397_588,
        2_863_311_529,
        3_221_225_470,
        3_579_139_411,
        3_937_053_352,
        4_294_967_296,
        5_726_623_061,
        7_158_278_826,
        8_589_934_591,
        10_021_590_356,
        11_453_246_121,
        12_884_901_886,
        14_316_557_651,
        15_748_213_416,
        17_179_869_184,
        22_906_492_245,
        28_633_115_306,
        34_359_738_367,
        40_086_361_428,
        45_812_984_489,
        51_539_607_550,
        57_266_230_611,
        62_992_853_672,
        68_719_476_736,
        91_625_968_981,
        114_532_461_226,
        137_438_953_471,
        160_345_445_716,
        183_251_937_961,
        206_158_430_206,
        229_064_922_451,
        251_971_414_696,
        274_877_906_944,
        366_503_875_925,
        458_129_844_906,
        549_755_813_887,
        641_381_782_868,
        733_007_751_849,
        824_633_720_830,
        916_259_689_811,
        1_007_885_658_792,
        1_099_511_627_776,
        1_466_015_503_701,
        1_832_519_379_626,
        2_199_023_255_551,
        2_565_527_131_476,
        2_932_031_007_401,
        3_298_534_883_326,
        3_665_038_759_251,
        4_031_542_635_176,
        4_398_046_511_104,
        5_864_062_014_805,
        7_330_077_518_506,
        8_796_093_022_207,
        10_262_108_525_908,
        11_728_124_029_609,
        13_194_139_533_310,
        14_660_155_037_011,
        16_126_170_540_712,
        17_592_186_044_416,
        23_456_248_059_221,
        29_320_310_074_026,
        35_184_372_088_831,
        41_048_434_103_636,
        46_912_496_118_441,
        52_776_558_133_246,
        58_640_620_148_051,
        64_504_682_162_856,
        70_368_744_177_664,
        93_824_992_236_885,
        117_281_240_296_106,
        140_737_488_355_327,
        164_193_736_414_548,
        187_649_984_473_769,
        211_106_232_532_990,
        234_562_480_592_211,
        258_018_728_651_432,
        281_474_976_710_656,
        375_299_968_947_541,
        469_124_961_184_426,
        562_949_953_421_311,
        656_774_945_658_196,
        750_599_937_895_081,
        844_424_930_131_966,
        938_249_922_368_851,
        1_032_074_914_605_736,
        1_125_899_906_842_624,
        1_501_199_875_790_165,
        1_876_499_844_737_706,
        2_251_799_813_685_247,
        2_627_099_782_632_788,
        3_002_399_751_580_329,
        3_377_699_720_527_870,
        3_752_999_689_475_411,
        4_128_299_658_422_952,
        4_503_599_627_370_496,
        6_004_799_503_160_661,
        7_505_999_378_950_826,
        9_007_199_254_740_991,
        10_508_399_130_531_156,
        12_009_599_006_321_321,
        13_510_798_882_111_486,
        15_011_998_757_901_651,
        16_513_198_633_691_816,
        18_014_398_509_481_984,
        24_019_198_012_642_645,
        30_023_997_515_803_306,
        36_028_797_018_963_967,
        42_033_596_522_124_628,
        48_038_396_025_285_289,
        54_043_195_528_445_950,
        60_047_995_031_606_611,
        66_052_794_534_767_272,
        72_057_594_037_927_936,
        96_076_792_050_570_581,
        120_095_990_063_213_226,
        144_115_188_075_855_871,
        168_134_386_088_498_516,
        192_153_584_101_141_161,
        216_172_782_113_783_806,
        240_191_980_126_426_451,
        264_211_178_139_069_096,
        288_230_376_151_711_744,
        384_307_168_202_282_325,
        480_383_960_252_852_906,
        576_460_752_303_423_487,
        672_537_544_353_994_068,
        768_614_336_404_564_649,
        864_691_128_455_135_230,
        960_767_920_505_705_811,
        1_056_844_712_556_276_392,
        1_152_921_504_606_846_976,
        1_537_228_672_809_129_301,
        1_921_535_841_011_411_626,
        2_305_843_009_213_693_951,
        2_690_150_177_415_976_276,
        3_074_457_345_618_258_601,
        3_458_764_513_820_540_926,
        3_843_071_682_022_823_251,
        4_227_378_850_225_105_576,
        MAX_VALUE
      ]

      @power_of_4_index = [
        0,
        3,
        14,
        23,
        32,
        41,
        50,
        59,
        68,
        77,
        86,
        95,
        104,
        113,
        122,
        131,
        140,
        149,
        158,
        167,
        176,
        185,
        194,
        203,
        212,
        221,
        230,
        239,
        248,
        257,
        266,
        275
      ]

      def self.num_leading_zeros(value)
        leading = 64
        while value.positive?
          value >>= 1
          leading -= 1
        end
        leading
      end

      # rubocop: disable Metrics/MethodLength
      def self.index_of(value)
        if value <= 0
          0
        elsif value <= 4
          value
        else
          lz = num_leading_zeros(value)
          shift = 64 - lz - 1
          prev_pwr2 = (value >> shift) << shift
          prev_pwr4 = prev_pwr2
          if shift.odd?
            shift -= 1
            prev_pwr4 >>= 1
          end
          base = prev_pwr4
          delta = base / 3
          offset = (value - base) / delta
          pos = offset + @power_of_4_index[shift / 2]
          if pos >= length - 1
            length - 1
          else
            pos + 1
          end
        end
      end
      # rubocop: enable Metrics/MethodLength

      def self.length
        @bucket_values.length
      end

      def self.get(index)
        @bucket_values[index]
      end

      def self.bucket(value)
        @bucket_values[index_of(value)]
      end

      def self.percentiles(counts, pcts, results)
        check_perc_args(counts, pcts, results)
        total = counts.inject(0, :+)

        pct_idx = 0
        prev = 0
        prev_p = 0
        prev_b = 0
        (0..length).each do |i|
          nxt = prev + counts[i]
          next_p = 100.0 * nxt / total
          next_b = @bucket_values[i]

          while pct_idx < pcts.length && next_p >= pcts[pct_idx]
            f = (pcts[pct_idx] - prev_p) / (next_p - prev_p)
            results[pct_idx] = f * (next_b - prev_b) + prev_b
            pct_idx += 1
          end

          break if pct_idx >= pcts.length

          prev = nxt
          prev_p = next_p
          prev_b = next_b
        end
      end

      def self.percentile(counts, perc)
        pcts = [perc]
        results = [0.0]
        percentiles(counts, pcts, results)
        results[0]
      end

      def self.counters(registry, id, prefix)
        (0...length).map do |i|
          tags = { statistic: 'percentile',
                   percentile: prefix + format('%04X', i) }
          counter_id = id.with_tags(tags)
          registry.counter_with_id(counter_id)
        end
      end

      def self.check_perc_args(counts, pcts, results)
        if counts.length != length
          raise ArgumentError(
            'counts is not the same size as the buckets array'
          )
        end

        raise ArgumentError('pcts cannot be empty') if pcts.empty?

        raise ArgumentError('pcts is not the same size as the results array') if
            pcts.length != results.length
      end
    end

    # Timer that buckets the counts to allow for estimating percentiles. This
    # timer type will track the data distribution for the timer by maintaining
    # a set of counters. The distribution  can then be used on the server side
    # to estimate percentiles while still allowing for arbitrary slicing and
    # dicing based on dimensions.
    #
    # <b>Percentile timers are expensive compared to basic timers from the
    # registry.</b> In particular they have a higher storage cost, worst case
    # ~300x, to maintain the data distribution. Be diligent about any additional
    # dimensions added to percentile timers and ensure they have a small bounded
    # cardinality. In addition it is highly recommended to set a range (using
    # the min and max parameters in the constructor which expect times in
    # seconds) to greatly restrict the worst case overhead.
    #
    class PercentileTimer
      def initialize(registry, name, tags = nil, min = 10e-3, max = 60)
        @registry = registry
        @id = Spectator::MeterId.new(name, tags)
        @min = min * 1e9
        @max = max * 1e9
        @timer = registry.timer_with_id(@id)
        @counters = PercentileBuckets.counters(registry, @id, 'T')
      end

      def record(nanos)
        @timer.record(nanos)
        restricted = restrict(nanos)
        idx = PercentileBuckets.index_of(restricted)
        @counters[idx].increment
      end

      def time
        start = @registry.clock.monotonic_time
        yield
        elapsed = @registry.clock.monotonic_time - start
        record(elapsed)
      end

      # return the given percentile in seconds
      def percentile(perc)
        counts = @counters.map(&:count)
        v = PercentileBuckets.percentile(counts, perc)
        v / 1e9
      end

      def total_time
        @timer.total_time
      end

      def count
        @timer.count
      end

      private

      def restrict(nanos)
        nanos = @max if nanos > @max
        nanos = @min if nanos < @min
        nanos.floor
      end
    end

    # Distribution summary that buckets the counts to allow for estimating
    # percentiles. This distribution summary type will track the data
    # distribution for the summary by maintaining a set of counters. The
    # distribution can then be used on the server side to estimate percentiles
    # while still allowing for arbitrary slicing and dicing based on dimensions.
    #
    # <b>Percentile distribution summaries are expensive compared to basic
    # distribution summaries from the registry.</b> In particular they have a
    # higher storage cost, worst case ~300x, to maintain the data distribution.
    # Be diligent about any additional dimensions added to percentile
    # distribution summaries and ensure they have a small bounded cardinality.
    # In addition it is highly recommended to set a threshold (using the min and
    # max parameters in the constructor) whenever possible to greatly restrict
    # the worst case overhead.
    class PercentileDistributionSummary
      def initialize(registry, name, tags = nil, min = 0, max = MAX_VALUE)
        @registry = registry
        @id = Spectator::MeterId.new(name, tags)
        @min = min
        @max = max
        @ds = registry.distribution_summary_with_id(@id)
        @counters = PercentileBuckets.counters(registry, @id, 'D')
      end

      def record(amount)
        @ds.record(amount)
        restricted = restrict(amount)
        idx = PercentileBuckets.index_of(restricted)
        @counters[idx].increment
      end

      # return the given percentile
      def percentile(perc)
        counts = @counters.map(&:count)
        PercentileBuckets.percentile(counts, perc)
      end

      def total_amount
        @ds.total_amount
      end

      def count
        @ds.count
      end

      private

      def restrict(nanos)
        nanos = @max if nanos > @max
        nanos = @min if nanos < @min
        nanos.floor
      end
    end
  end
end
