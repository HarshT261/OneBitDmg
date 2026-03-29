import React, { Fragment } from 'react'
import { useConfig, DocsThemeConfig } from 'nextra-theme-docs'
import LogoMark from '@/components/LogoMark'
import FooterMenu from '@/components/FooterMenu'
import JSONLD from '@/components/JSONLD'
import Link from 'next/link'
import { LibraryBig, Blocks, BrainCircuit, Computer } from 'lucide-react'
import { AiOutlineGithub } from 'react-icons/ai'
import { BiLogoDiscordAlt } from 'react-icons/bi'
import { RiTwitterXFill } from 'react-icons/ri'
import Navbar from '@/components/Navbar'

const defaultUrl = 'https://github.com/anirudhmlik/onebit'
const defaultOgImage =
  'https://github.com/anirudhmlik/onebit/raw/main/OneBitDmg/docs/public/assets/images/app-preview.png'
const defaultLogoImage =
  'https://github.com/anirudhmlik/onebit/raw/main/OneBitDmg/docs/public/assets/images/onebit-logo.png'

const structuredData = {
  '@context': 'https://schema.org',
  '@type': 'Organization',
  'name': 'OneBit AI',
  'url': `${defaultUrl}`,
  'logo': `${defaultLogoImage}`,
}

const config: DocsThemeConfig = {
  logo: (
    <span className="flex gap-x-8 items-center">
      <div className="flex">
        <LogoMark />
        <span className="ml-2 text-lg font-semibold">OneBit AI</span>
      </div>
    </span>
  ),
  docsRepositoryBase:
    'https://github.com/anirudhmlik/onebit/tree/main/OneBitDmg/docs',
  feedback: {
    content: 'Question? Give us feedback →',
    labels: 'feedback',
  },
  editLink: {
    text: 'Edit this page on GitHub →',
  },
  useNextSeoProps() {
    return {
      titleTemplate: '%s - OneBit AI',
      twitter: {
        cardType: 'summary_large_image',
      },
      openGraph: {
        type: 'website',
      },
    }
  },
  navbar: {
    component: <Navbar />,
  },
  sidebar: {
    defaultMenuCollapseLevel: 1,
    autoCollapse: true
  },
  darkMode: false,
  toc: {
    backToTop: true,
  },
  head: function useHead() {
    const { title, frontMatter } = useConfig()

    return (
      <Fragment>
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta httpEquiv="Content-Language" content="en" />
        <title>{frontMatter?.title || title || 'OneBit AI'}</title>
        <meta name="og:title" content={frontMatter?.title || title || 'OneBit AI'} />
        <meta
          name="description"
          content={
            frontMatter?.description ||
            `Run LLMs like Qwen3 or Llama3 locally and offline on your computer, or connect to remote AI APIs like OpenAI's GPT-4 or Groq.`
          }
        />
        <meta
          name="og:description"
          content={
            frontMatter?.description ||
            `Run LLMs like Qwen3 or Llama3 locally and offline on your computer, or connect to remote AI APIs like OpenAI's GPT-4 or Groq.`
          }
        />
        <link
          rel="canonical"
          href={defaultUrl}
        />
        <meta
          property="og:url"
          content={defaultUrl}
        />
        <meta
          property="og:image"
          content={defaultOgImage}
        />
        <meta property="og:image:alt" content="OneBit AI" />
        <meta
          name="keywords"
          content={
            frontMatter?.keywords?.map((keyword: string) => keyword) || [
              'OneBit AI',
              'Customizable Intelligence, LLM',
              'local AI',
              'privacy focus',
              'free and open source',
              'private and offline',
              'conversational AI',
              'no-subscription fee',
              'large language models',
              'build in public',
              'remote team',
              'how we work',
            ]
          }
        />
        <JSONLD data={structuredData} />
      </Fragment>
    )
  },
  footer: {
    text: <FooterMenu />,
  },
  nextThemes: {
    defaultTheme: 'light',
    forcedTheme: 'light',
  },
}

export default config
