require_relative './lib'

class TestShorthandSyntax < IntegrationTest

  def get_project_binaries prj
    exe_dir = File.join(prj.bin_dir, 'bin')
    assert File.directory? exe_dir
    return Dir[exe_dir + '/**/*'].filter {
        # on multi-configuration generators (like Visual Studio) the executables will be in bin/<Config>
        # also filter-out other artifacts like .pdb or .dsym
        !File.directory?(_1) && File.stat(_1).executable?
      }.map {
        # remove .exe extension if any (there will be one on Windows)
        File.basename(_1, '.exe')
      }.sort
  end

  def test_create_with_commit_sha
    prj = make_project from_template: 'using-adder'
    prj.create_lists_from_default_template package:
    'CPMAddPackage("gh:cpm-cmake/testpack-adder#cad1cd4b4cdf957c5b59e30bc9a1dd200dbfc716")'
    assert_success prj.configure

    cache = prj.read_cache
    assert_equal 1, cache.packages.size
    assert_equal '0', cache.packages['testpack-adder'].ver

    assert_success prj.build
    exes = get_project_binaries prj
    # No adder projects were built as EXCLUDE_FROM_ALL is implicitly set
    assert_equal ['using-adder'], exes
  end

  def test_create_with_version
    prj = make_project from_template: 'using-adder'
    prj.create_lists_from_default_template package:
    'CPMAddPackage("gh:cpm-cmake/testpack-adder@1.0.0")'
    assert_success prj.configure

    cache = prj.read_cache
    assert_equal 1, cache.packages.size
    assert_equal '1.0.0', cache.packages['testpack-adder'].ver

    assert_success prj.build
    exes = get_project_binaries prj
    assert_equal ['using-adder'], exes
  end

  def test_create_with_all
    prj = make_project from_template: 'using-adder'
    prj.create_lists_from_default_template package:
    'CPMAddPackage(
      URI "gh:cpm-cmake/testpack-adder@1.0.0"
      EXCLUDE_FROM_ALL false
    )'
    assert_success prj.configure

    cache = prj.read_cache
    assert_equal cache.packages.size, 1
    assert_equal cache.packages['testpack-adder'].ver, '1.0.0'
    
    assert_success prj.build
    exes = get_project_binaries prj
    assert_equal exes, ['simple', 'test-adding', 'using-adder']
  end

  def test_create_with_tests_but_without_examples
    prj = make_project from_template: 'using-adder'
    prj.create_lists_from_default_template package:
    'CPMAddPackage(
      URI "gh:cpm-cmake/testpack-adder@1.0.0"
      OPTIONS "ADDER_BUILD_EXAMPLES OFF" "ADDER_BUILD_TESTS TRUE"
      EXCLUDE_FROM_ALL false
    )'
    assert_success prj.configure

    cache = prj.read_cache
    assert_equal cache.packages.size, 1
    assert_equal cache.packages['testpack-adder'].ver, '1.0.0'
    
    assert_success prj.build
    exes = get_project_binaries prj
    assert_equal exes, ['test-adding', 'using-adder']
  end

end
