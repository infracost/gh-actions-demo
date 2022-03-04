package infracost

deny[out] {
	maxDiff = 1750.0

	msg := sprintf(
		"Total monthly cost diff must be less than $%.2f (actual diff is $%.2f)",
		[maxDiff, to_number(input.diffTotalMonthlyCost)]
	)

  out := {
    "msg": msg,
    "failed": to_number(input.diffTotalMonthlyCost) >= maxDiff
  }
}

deny[out] {
	r := input.projects[_].breakdown.resources[_]
	startswith(r.name, "aws_instance.")

	maxHourlyCost := 2.5

	msg := sprintf(
		"AWS instances must cost less than $%.2f\\hr (%s costs $%.2f\\hr).",
		[maxHourlyCost, r.name, to_number(r.hourlyCost)]
	)

  out := {
    "msg": msg,
    "failed": to_number(r.hourlyCost) > maxHourlyCost
  }
}

deny[out] {
	r := input.projects[_].breakdown.resources[_]
	startswith(r.name, "aws_instance.")

	baseHourlyCost := to_number(r.costComponents[_].hourlyCost)

	sr_cc := r.subresources[_].costComponents[_]
	sr_cc.name == "Provisioned IOPS"
	iopsHourlyCost := to_number(sr_cc.hourlyCost)

	msg := sprintf(
		"AWS instance IOPS must cost less than compute usage (%s IOPS $%.2f\\hr, usage $%.2f\\hr).",
		[r.name, iopsHourlyCost, baseHourlyCost]
	)

  out := {
    "msg": msg,
    "failed": 	iopsHourlyCost > baseHourlyCost
  }
}