#!/usr/bin/env zx

import { spinner } from 'zx/experimental'

const CONFIG_FILES = [
  '.zshrc',
  '.aliases',
  '.p10k.zsh',
]

const errorText = chalk.bold.red
const warningText = chalk.bold.yellow
const infoText = chalk.bold.white
const positiveText = chalk.bold.green

// Set verbosity to silent. Default is true. Verbosity may be useful for development.
$.verbose = false

const reportError = (message, error = new Error()) => {
  console.log(errorText(message))
  console.error(error)
}

const getFileLinkStats = async (path) => {
  let stats = null
  try {
    stats = await fs.lstat(path)
  } catch {
    // We want to fail gracefully.
    // fs.lstat throws when the path is invalid or the symlink is broken.
  }
  return stats
}

const backup = async (file) => {
  try {
    const exists = await fs.pathExists(file)
    const backupFileStats = await getFileLinkStats(file)

    // If the file exists and is not a symbolic link
    if (exists && !backupFileStats.isSymbolicLink()) {
      await $`mv ${file} ${file}.backup`
      console.log(infoText(`-> Moved your old ${file} to ${file}.backup`))
    }
  } catch (error) {
    reportError('Problem backing up file', error)
    process.exit(1)
  }
}

const symlink = async (file, target) => {
  try {
    const fileExists = await fs.pathExists(file)
    const targetExists = await fs.pathExists(target)

    // If the file exists, but the target link does not
    if (fileExists && !targetExists) {
      await $`ln -fs ${file} ${target}`
      console.log(infoText(`-> Symlinked ${file} to ${target}`))
    }
  } catch (error) {
    reportError(`Problem creating symlink for ${file} at ${target}`, error)
    process.exit(1)
  }
}

const installOhmyzsh = async () => {
  try {
    const exists = await fs.pathExists(path.join(os.homedir(), '.oh-my-zsh'))

    if (exists) {
      console.log(warningText('Skipping oh-my-zsh, already installed!'))
    } else {
      const installMessage = '-> Installing oh-my-zsh... '
      await spinner(
        infoText(installMessage),
        () => $`sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`
      )
      console.log(infoText(installMessage), positiveText('Done'))
    }
  } catch (error) {
    reportError('Problem installing oh-my-zsh', error)
    process.exit(1)
  }
}

const installP10K = async () => {
  try {
    const p10kPath = path.join(os.homedir(), '.oh-my-zsh', 'custom', 'themes', 'powerlevel10k')
    const exists = await fs.pathExists(p10kPath)

    if (exists) {
      console.log(warningText('Skipping powerlevel10k, already installed!'))
    } else {
      const installMessage = '-> Installing powerlevel10k... '
      await spinner(
        infoText(installMessage),
        () => $`git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${p10kPath}`
      )
      console.log(infoText(installMessage), positiveText('Done'))
    }
  } catch (error) {
    reportError('Problem installing powerlevel10k', error)
    process.exit(1)
  }
}

const installPlugin = async (pluginName, pluginDir, pluginRepo) => {
  const pluginExists = await fs.pathExists(pluginDir)
  if (pluginExists) {
    console.log(warningText(`Skipping ${pluginName}, already installed!`))
  } else {
    const installMessage = `-> Installing ${pluginName}... `
    await spinner(infoText(installMessage), () => $`git clone ${pluginRepo} ${pluginDir}`)
    console.log(infoText(installMessage), positiveText('Done'))
  }
}

const installZSHPlugins = async () => {
  try {
    const pluginsDir = path.join(os.homedir(), '.oh-my-zsh', 'custom', 'plugins')
    await fs.ensureDir(pluginsDir)

    installPlugin(
      'zsh-syntax-highlighting',
      path.join(pluginsDir, 'zsh-syntax-highlighting'),
      'https://github.com/zsh-users/zsh-syntax-highlighting'
    )

    installPlugin(
      'zsh-autosuggestions',
      path.join(pluginsDir, 'zsh-autosuggestions'),
      'https://github.com/zsh-users/zsh-autosuggestions'
    )

  } catch(error) {
    reportError('Problem installing zsh plugins', error)
    process.exit(1)
  }
}

const setupConfigFiles = async () => {
  try {
    for (const fileName of CONFIG_FILES) {
      const target = path.join(os.homedir(), fileName)
      const file = path.join(os.homedir(), 'dotfiles', 'config', fileName)
      await backup(target)
      await symlink(file, target)
    }
  } catch (error) {
    reportError('Problem setting up config files', error)
    process.exit(1)
  }
}

const installCargo = async () => {
  try {
    // Using which.sync because async will not recognize nothrow: true (maybe a bug?)
    // We do not want to throw when the command doesn't exist, but rather, take action on it.
    const hasCargo = which.sync('cargo', { nothrow: true })
    if (!hasCargo) {
      const installMessage = '-> Installing Rust and Cargo... '
      await spinner(infoText(installMessage), () => $`curl https://sh.rustup.rs -sSf | sh -s -- -y`)
      console.log(infoText(installMessage), positiveText('Done'))
    }
  } catch (error) {
    reportError('Problem installing cargo', error)
    process.exit(1)
  }
}

const installGitDelta = async () => {
  try {
    // Using which.sync because async will not recognize nothrow: true (maybe a bug?)
    // We do not want to throw when the command doesn't exist, but rather, take action on it.
    const hasDelta = which.sync('delta', { nothrow: true })
    if (!hasDelta) {
      const installMessage = '-> Installing git-delta... '
      await spinner(infoText(installMessage), () => $`cargo install git-delta --quiet`)
      console.log(infoText(installMessage), positiveText('Done'))
    }
  } catch (error) {
    reportError('Problem installing cargo', error)
    process.exit(1)
  }
}

const runTasks = async () => {
  // const isSpin = !!process.env.SPIN

  await installOhmyzsh()
  await installP10K()
  await installZSHPlugins()
  await setupConfigFiles()
  await installCargo()
  await installGitDelta()
}

runTasks()
