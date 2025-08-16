#!/usr/bin/env sh

apk --no-cache add curl

if [ "${VERSION}" = "7.2" ]; then
  # Special pattern for PHP 7.2
  curl --silent --fail http://app:80 | grep "PHP Version ${VERSION}"
else
  # Standard pattern for other versions
  curl --silent --fail http://app:80 | grep "PHP ${VERSION}"
fi
