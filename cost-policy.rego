package infracost

# This policy who
deny[out] {
	maxDiff = 2000.0

	msg := sprintf(
		"Total monthly cost diff must be less than $%.2f (actual diff is $%.2f)",
		[maxDiff, to_number(input.diffTotalMonthlyCost)],
	)

  out := {
    "msg": msg,
    "failed": to_number(input.diffTotalMonthlyCost) >= maxDiff
  }
}