# The following are example policies that the `infracost comment` command can use to add 
# policy output to your PR comments.
#
# Click the "Evaluate" button on the top right of the playground to show the generated output.
# 
# To use this playground to generate your own rules you can:
#
# 1. generate a new infracost breakdown output using `infracost breakdown --path plan.json --format json --out-file infracost.json`
#    and then pasting the contents of infracost.json into the "Input" section to the right.
# 2. Rewrite, duplicate or delete some of the rules below to fit your own use case.
# 3. Run the "Evaluate" button and make sure that you have an output with a single property "deny" which contains an array
#    of rule outputs. For example:
#				
#       {
#   		"deny": [
#       		{
#           		"failed": false,
#          			"msg": "AWS instance IOPS must cost less than compute usage (aws_instance.web_app IOPS $0.07\\hr, usage $0.77\\hr)."
#       		},
#       		{
#           		"failed": false,
#           		"msg": "AWS instances must cost less than $2.00\\hr (aws_instance.web_app costs $1.02\\hr)."
#				}
#           ]
# 		}
# 
# 4. Save this policy file to your infra project with an appropriate name, e.g: policy.rego.
# 5. Modify the `infracost comment` command that posts your cost estimates PR comment to include the `--policy-path=policy.rego` flag. 

package infracost # your policy files must be under the "infracost" package

# This example shows you how you can create a policy that will fail if the infracost `diffTotalMonthlyCost`
# value is greater than 500 dollars.
deny[out] {
	# maxDiff defines the threshold that you require the cost estimate to be below.
	maxDiff = 500.0

	# msg defines the output that will be shown in PR comments under the Policy Checks/Failures section.
	msg := sprintf(
		"Total monthly cost diff must be less than $%.2f (actual diff is $%.2f)",
		[maxDiff, to_number(input.diffTotalMonthlyCost)],
	)

	# out defines the output for this policy. This output must be formatted with a `msg` and `failed` property.
  	out := {
    	# the msg you want to display in your PR comment
    	"msg": msg,
        # a boolean value that determines if this policy has failed.
        # In this case if the Infracost breakdown output diffTotalMonthlyCost is greater that $500. 
    	"failed": to_number(input.diffTotalMonthlyCost) >= maxDiff
  	}
}

# This example shows you how you can create a policy that will fail if your aws instance hourly 
# costs are above $2.0.
deny[out] {
    # find the aws instance resources that are contained in the infracost output.
    # See the "Input" section to the right for more info.
	r := input.projects[_].breakdown.resources[_]
	startswith(r.name, "aws_instance.")

    # maxHourlyCost is the cost threshold that you don't want your aws instance hourly cost to exceed.
	maxHourlyCost := 2.0
	
    # msg defines the output that will be shown in PR comments under the Policy Checks/Failures section.
	msg := sprintf(
		"AWS instances must cost less than $%.2f\\hr (%s costs $%.2f\\hr).",
		[maxHourlyCost, r.name, to_number(r.hourlyCost)],
	)
    
    # out defines the output for this policy. This output must be formatted with a `msg` and `failed` property.
  	out := {
    	# the msg you want to display in your PR comment
    	"msg": msg,
        # a boolean value that determines if this policy has failed.
        # In this case if the the aws instance hourly cost shown in the infracost breakdown output is more than $2.0.
    	"failed": to_number(r.hourlyCost) > maxHourlyCost
  	}
}

# This example shows you how you can create a policy that will fail if your aws instance IOPs 
# costs are above the base hourly cost of the instance.
deny[out] {
    # find the aws instance resources that are contained in the infracost output.
    # See the "Input" section to the right for more info.
	r := input.projects[_].breakdown.resources[_]
	startswith(r.name, "aws_instance.")

	# baseHourlyCost reflects the hourly cost for the aws instance resource.
	baseHourlyCost := to_number(r.costComponents[_].hourlyCost)

	# find the provisioned IOPs for the aws instance resource by filtering
    # the costComponents of the resource based on their name.
	sr_cc := r.subresources[_].costComponents[_]
	sr_cc.name == "Provisioned IOPS"
	iopsHourlyCost := to_number(sr_cc.hourlyCost)
    
    # msg defines the output that will be shown in PR comments under the Policy Checks/Failures section.
	msg := sprintf(
		"AWS instance IOPS must cost less than compute usage (%s IOPS $%.2f\\hr, usage $%.2f\\hr).",
		[r.name, iopsHourlyCost, baseHourlyCost],
	)
    	
    # out defines the output for this policy. This output must be formatted with a `msg` and `failed` property.
  	out := {
    	# the msg you want to display in your PR comment
    	"msg": msg,
        # a boolean value that determines if this policy has failed.
        # In this case if the the aws instance iops cost shown in the infracost breakdown output is more than instance hourly cost.
    	"failed": 	iopsHourlyCost > baseHourlyCost
  	}
}
