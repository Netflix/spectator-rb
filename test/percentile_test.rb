require 'test_helper'
require 'spectator/registry'
require 'spectator/histogram/percentiles'

module Spectator
  module Histogram
    MAX_VALUE = 9_223_372_036_854_775_807

    class PercentileTest < Minitest::Test
      def test_length
        assert_equal PercentileBuckets.length, 276
      end

      def test_index_of
        assert_equal(0, PercentileBuckets.index_of(-1))
        assert_equal(0, PercentileBuckets.index_of(0))
        assert_equal(1, PercentileBuckets.index_of(1))
        assert_equal(2, PercentileBuckets.index_of(2))
        assert_equal(3, PercentileBuckets.index_of(3))
        assert_equal(4, PercentileBuckets.index_of(4))

        assert_equal(25, PercentileBuckets.index_of(87))

        assert_equal(
          PercentileBuckets.length - 1,
          PercentileBuckets.index_of(MAX_VALUE)
        )
      end

      def test_index_of_sanity_check
        srand(42)
        (1..100_000).each do |_i|
          v = rand(-MAX_VALUE..MAX_VALUE)
          if v.negative?
            assert_equal(0, PercentileBuckets.index_of(v))
          else
            b = PercentileBuckets.get(PercentileBuckets.index_of(v))
            assert(v <= b)
          end
        end
      end

      def test_bucket_sanity_check
        srand(42)
        (1..10_000).each do |_i|
          v = rand(-MAX_VALUE..MAX_VALUE)
          if v.negative?
            assert_equal(1, PercentileBuckets.bucket(v))
          else
            b = PercentileBuckets.bucket(v)
            assert(v <= b)
          end
        end
      end

      def within_threshold(expected, results, threshold)
        assert_equal(expected.length, results.length)
        expected.zip(results).each do |e, r|
          assert_in_delta(e, r, threshold)
        end
      end

      def test_percentiles
        counts = [0] * PercentileBuckets.length
        (0...100_000).each do |i|
          counts[PercentileBuckets.index_of(i)] += 1
        end

        pcts = [0.0, 25.0, 50.0, 75.0, 90.0, 95.0, 98.0, 99.0, 99.5, 100.0]
        results = [0.0] * pcts.length

        PercentileBuckets.percentiles(counts, pcts, results)

        expected = [0.0, 25e3, 50e3, 75e3, 90e3,
                    95e3, 98e3, 99e3, 99.5e3, 100e3]
        threshold = 0.1 * 100_000 # quick check, should be within 10% of total
        within_threshold(expected, results, threshold)

        # Further check each value is within 10% of actual percentile
        results.each_with_index do |r, idx|
          threshold = 0.1 * expected[idx] + 1e-12
          assert_in_delta(expected[idx], r, threshold)
        end
      end

      def test_percentile
        counts = [0] * PercentileBuckets.length
        (0...100_000).each do |i|
          counts[PercentileBuckets.index_of(i)] += 1
        end

        pcts = [0.0, 25.0, 50.0, 75.0, 90.0, 95.0, 98.0, 99.0, 99.5, 100.0]
        pcts.each do |p|
          expected = p * 1e3
          threshold = 0.1 * expected + 1e-12
          actual = PercentileBuckets.percentile(counts, p)
          assert_in_delta(expected, actual, threshold)
        end
      end
    end

    class PercentileTimerTest < Minitest::Test
      def check_percentiles(timer, start)
        (0...100_000).each do |i|
          timer.record(i * 1e6) # convert millis to nanos
        end
        (start..100).each do |i|
          expected = i
          threshold = 0.15 * expected + 1e-12
          assert_in_delta(expected, timer.percentile(i), threshold)
        end
      end

      def test_percentile
        r = Spectator::Registry.new({})
        t = PercentileTimer.new(r, 'test', nil, 0, MAX_VALUE)
        check_percentiles(t, 0)
      end

      def test_with_threshold
        r = Spectator::Registry.new({})
        t = PercentileTimer.new(r, 'test', nil, 10, 100)
        check_percentiles(t, 10)
      end

      def test_with_threshold_2
        r = Spectator::Registry.new({})
        t = PercentileTimer.new(r, 'test', nil, 0, 100)
        check_percentiles(t, 0)
      end
    end

    class PercentileDistSummaryTest < Minitest::Test
      def check_percentiles(dist_summary, start)
        (0...100_000).each do |i|
          dist_summary.record(i)
        end
        (start..100).each do |i|
          expected = i * 1e3
          threshold = 0.15 * expected + 1e-12
          assert_in_delta(expected, dist_summary.percentile(i), threshold)
        end
      end

      def test_percentile
        r = Spectator::Registry.new({})
        ds = PercentileDistributionSummary.new(r, 'test', nil, 0, MAX_VALUE)
        check_percentiles(ds, 0)
      end

      def test_with_threshold
        r = Spectator::Registry.new({})
        ds = PercentileDistributionSummary.new(r, 'test', nil, 10, 100_000)
        check_percentiles(ds, 10)
      end

      def test_with_threshold_2
        r = Spectator::Registry.new({})
        ds = PercentileDistributionSummary.new(r, 'test', nil, 25e3, 100e3)
        check_percentiles(ds, 25)
      end
    end
  end
end
