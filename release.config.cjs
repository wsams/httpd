module.exports = {
  branches: ['master'],
  plugins: [
    '@semantic-release/commit-analyzer',
    '@semantic-release/release-notes-generator',
    '@semantic-release/github',
    [
      '@semantic-release/exec',
      {
        publishCmd:
          'PUSH=true FLOAT_BASE=latest FLOAT_PHP=php FLOAT_PYTHON=python ./scripts/build-images.sh ${nextRelease.version}',
      },
    ],
  ],
};
