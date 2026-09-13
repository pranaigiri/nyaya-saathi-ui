# Fix: Web URL previews in WhatsApp, Slack, and X share as a plain bare link

> Follow the steps in order. Run every check. If anything in "STOP if"
> happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/flutter-web-og-image
- **Needs new dependency**: none

## Why

Shared links to Nyaya Saathi on social or chat platforms show no preview card. Adding Open Graph and Twitter Card metadata provides a rich title, description, and preview image.

## Where

```html
<!-- web/index.html:20 — current -->
  <meta charset="UTF-8">
  <meta content="IE=Edge" http-equiv="X-UA-Compatible">
  <meta name="description" content="A new Flutter project.">
```

## The fix

Add Open Graph and Twitter meta tags to `<head>` in `web/index.html`:
```html
<!-- target: in web/index.html -->
  <meta name="description" content="Legal Aid service application for Sikkim State Legal Services Authority (SLSA).">

  <!-- Open Graph / Facebook -->
  <meta property="og:type" content="website">
  <meta property="og:title" content="Nyaya Saathi — Sikkim State Legal Services Authority">
  <meta property="og:description" content="Empowering citizens of Sikkim with seamless, free access to legal aid, application tracking, and legal services.">
  <meta property="og:image" content="https://nyayasaathi.sikkim.gov.in/assets/images/app_logo.png">

  <!-- Twitter / X -->
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="Nyaya Saathi — Sikkim State Legal Services Authority">
  <meta name="twitter:description" content="Empowering citizens of Sikkim with seamless, free access to legal aid, application tracking, and legal services.">
  <meta name="twitter:image" content="https://nyayasaathi.sikkim.gov.in/assets/images/app_logo.png">
```

## Steps

1. In `web/index.html`, replace generic description with comprehensive Open Graph and Twitter metadata tags.

## Check it

`grep -c "og:title" web/index.html` -> 1.
`grep -c "twitter:card" web/index.html` -> 1.

## Don't touch

- Base href configuration in `web/index.html`.

## STOP if

- Meta tags introduce malformed HTML.

## When you're done

Sharing the Nyaya Saathi web portal generates a rich preview card with official branding and description.
