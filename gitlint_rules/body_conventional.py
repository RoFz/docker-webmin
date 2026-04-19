import re

from gitlint.rules import CommitMessageBody, CommitRule, LineRule, RuleViolation

_TYPES = "feat|fix|chore|ci|test|refactor|docs|style|perf|build|revert"
_BODY_LINE = re.compile(rf"^- (?:{_TYPES})(?:\([^()]+\))?: \S")


class BodyRequired(CommitRule):
    name = "body-required"
    id = "UC1"

    def validate(self, commit):
        if not any(line.strip() for line in commit.message.body):
            return [RuleViolation(self.id, "Commit body is required: list changes as '- type[(scope)]: description' lines")]
        return []


class BodyConventionalLine(LineRule):
    name = "body-conventional-line"
    id = "UC2"
    target = CommitMessageBody

    def validate(self, line, commit):
        if not line.strip():
            return []
        if not _BODY_LINE.match(line):
            return [RuleViolation(self.id, "Body line must be a conventional commit entry: '- type[(scope)]: description'")]
        return []
