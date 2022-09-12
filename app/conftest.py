import pytest

def pytest_addoption(parser):
    parser.addoption("--browser", action="store", default="chrome")
    parser.addoption("--headless", action="store", default=False)


# Pass the browser type and headless status from argument to the framework
def pytest_generate_tests(metafunc):
    option_value_browser = metafunc.config.option.browser
    option_value_headless = metafunc.config.option.headless

    if 'browser' in metafunc.fixturenames and option_value_browser is not None:
        metafunc.parametrize("browser", [option_value_browser])
    if 'headless' in metafunc.fixturenames and option_value_headless is not None:
        metafunc.parametrize("headless", [option_value_headless])


# Make docstring as a part of the outcome result for test case description
@pytest.hookimpl(hookwrapper=True)
def pytest_runtest_makereport(item):
    outcome = yield
    report = outcome.get_result()
    test_fn = item.obj
    docstring = getattr(test_fn, '__doc__')
    if docstring:
        report.nodeid = docstring


# Include the test environment as a part of the html report
@pytest.fixture(autouse=True, scope='session')
def _environment(request):
    browser = request.config.getoption('--browser')
    request.config._metadata['Environment'] = "STAGING"
    request.config._metadata['Browser'] = browser.upper()
