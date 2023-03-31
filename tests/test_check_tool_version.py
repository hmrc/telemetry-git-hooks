import pytest

from hooks.check_tool_versions import main


@pytest.mark.parametrize(
    ("tool", "expected_retval", "expected_response"),
    (
        ("python", 0, ""),
        ("poetry", 0, ""),
        ("test-missing", 1, ".test-missing-version file not found\n"),
        (
            "test-mismatch",
            1,
            "version mismatch for test-mismatch .test-mismatch-version specifies version 0.0.1 but .tools-versions specifies 0.0.0\n",
        ),
        ("test-no-tool", 1, "test-no-tool not in .tool-versions\n"),
    ),
)
def test_main(capsys, tool, expected_retval, expected_response):
    ret = main(("--tools", tool))
    assert ret == expected_retval
    if expected_retval == 1:
        stdout, _ = capsys.readouterr()
        assert stdout == expected_response
