[![Codacy Badge](https://api.codacy.com/project/badge/Grade/ab8e513f5e8d48ec8ac8afd945293f8a)](https://www.codacy.com/app/sdcplatform/response-management-ui?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=ONSdigital/response-management-ui&amp;utm_campaign=Badge_Grade)  [![Docker Pulls](https://img.shields.io/docker/pulls/sdcplatform/response-management-ui.svg)]()

# Field Staff Data Repository User Interface

## Running
To run this project in development using its [Rackup](http://rack.github.io/) file use:

  `bundle exec rackup config.ru` (the `config.ru` may be omitted as Rack looks for this file by default)

and access using [http://localhost:9292](http://localhost:9292)

## Running the Mock

In the event that the supporting spring boot app is not available there is a ruby Mock

navigate to mock/fsdr

  `bundle exec rackup -p 9290`

end points can be accessed at [http://localhost:9290](http://localhost:9290)
  /fieldforce
  /fieldforce/:fieldworkerid

## Environment Variables
The environment variables below must be provided:

## Compiling the Style Sheet using Sass
This project uses the CSS preprocessor [Sass](http://sass-lang.com/) so that features such as variables and mixins that don't exist in pure CSS can be used. The SCSS syntax is used rather than the older Sass syntax. The application style sheet `public/screen.css` is compiled from the main Sass style sheet `views/stylesheets/screen.scss`, which in turn imports the other Sass style sheets in the same directory. To generate `screen.css` from `screen.scss` use:

 `sass -t compressed screen.scss ../../public/css/screen.css`

 from within the `views/stylesheets` directory. Omit `-t compressed` for non-minified CSS output.



## Copyright
Copyright (C) 2019 Crown Copyright (Office for National Statistics)
