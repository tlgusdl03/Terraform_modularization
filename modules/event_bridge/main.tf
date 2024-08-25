module "eventbridge" {
  source = "terraform-aws-modules/eventbridge/aws"

  create_bus = false

  rules = var.eventBridgeRule

  targets = var.eventBridgeTarget

  tags = {
    Name = var.eventBridgeBusName
  }
}