<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->
[![Python][terraform-shield]][tf-version]
[![Latest][version-shield]][release-url]
[![Tests][test-shield]][test-url]
[![License][license-shield]][license-url]
<!-- [![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url] -->

!-- PROJECT LOGO -->
<br />
<p align="center">
  <!-- <a href="https://github.com/jingood2/terraform-template">
    <img src="images/logo.png" alt="Logo" width="80" height="80">
  </a> -->

  <h3 align="center">Terraform template with pre-commit and unit test</h3>

  <p align="center">
    Create a Terraform module with CICD already setup.
    <!-- <br />
    <a href="https://github.com/jingood2/terraform-template"><strong>Explore the docs »</strong></a>
    <br /> -->
    <br />
    <!-- <a href="https://github.com/jingood2/terraform-template">View Demo</a>
    · -->
    <a href="https://github.com/jingood2/terraform-template/issues">Report Bug</a>
    ·
    <a href="https://github.com/jingood2/terraform-template/issues">Request Feature</a>
    ·
    <!-- <a href="https://la-tech.co/post/hypermodern-cloudformation/getting-started/">Guide</a> -->
  </p>
</p>

## About The Project

<!-- [![Product Name Screen Shot][product-screenshot]](https://example.com) -->

This "Hello World" module is a template and a guide to creating Terraform modules. Its purpose is to demonstrate Terraform module best practices and provide a template with CI/CD preconfigured.


<!-- ACKNOWLEDGEMENTS -->
## Acknowledgements
* [Release Drafter](https://github.com/release-drafter/release-drafter)
* [pre-commit-terraform]
* [terraform-docs]
* [TFLint]
* [tfsec]
* [checkov]
* [Terratest]
* [Best-README-Template](https://github.com/othneildrew/Best-README-Template)
<br/>
<br/>

## Prerequisites
1. Install tools python3
```
$ brew install python3
python3 --version
```
2. Install go
```
$ brew install go
```
3. Install pre-commit go dependencies like terraform-docs tfsec
```
$ brew install pre-commit tfswitch tflint tfsec checkov terraform-docs
```

### Everything below this line is generated via [terraform-docs]

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.19.0 |

## Modules

No modules.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami"></a> [ami](#input\_ami) | Ubuntu AMI ID | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type | `string` | n/a | yes |
| <a name="input_name_tag"></a> [name\_tag](#input\_name\_tag) | Name of the EC2 instance | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | Instance ID |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | Public IP Address of EC2 instance |
<!-- END_TF_DOCS -->
