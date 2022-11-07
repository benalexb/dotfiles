#!/usr/bin/env zx

const errorText = chalk.bold.red;
const warningText = chalk.bold.yellow;

const reportError = (message, error = new Error()) => {
  console.log(errorText(message))
  console.error(error)
}

// const symlink = (file, target) => {
//   // Check if file and target exist
//   // Only create symlink if file and target both exist.
//   // Should we fail gracefully or exit the script with an error?
// }

// const backup = (file) => {
//   // Check if the file to be backed up actually exists
//   // Only back it up if it actually exists
//   // Should we fail gracefully or exit the script with an error?
// }

const installOhmyzsh = async () => {
  try {
    const exists = await fs.pathExists(path.join(os.homedir(), '.oh-my-zsh'))

    if (exists) {
      console.log(warningText('Skipping oh-my-zsh, already installed!'))
    } else {
      await $`sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`
    }
  } catch (error) {
    reportError('Problem installing oh-my-zsh', error)
    process.exit(1)
  }
}

const installP10K = async () => {
  try {
    const p10kPath = path.join(
      os.homedir(),
      '.oh-my-zsh',
      'custom',
      'themes',
      'powerlevel10k'
    )
    const exists = await fs.pathExists(p10kPath)

    if (exists) {
      console.log(warningText('Skipping powerlevel10k, already installed!'))
    } else {
      await $`git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${p10kPath}`
    }
  } catch (error) {
    reportError('Problem installing powerlevel10k', error)
    process.exit(1)
  }
}

const runTasks = async () => {
  // const isSpin = !!process.env.SPIN

  await installOhmyzsh()
  await installP10K()
}

runTasks()
