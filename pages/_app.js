import '../styles/globals.css'
import Link from 'next/link'

function MyApp({ Component, pageProps }) {
  return (
    <div className>
      <nav className="border-b p-6">
        <p className="text-4xl font-bold">Rwema NFT Market</p>
        <div className="flex mt-4"></div>
        <ul>
          <Link href="/">
            <a className="mr-4 text-pink-500">Home</a>
          </Link>
          <Link href="/create-item">
            <a className="mr-6 text-pink-500">Sell Asset</a>
          </Link>
          <Link href="/my-assets">
            <a className="mr-6 text-pink-500">My Assets</a>
          </Link>
          <Link href="/creator-dashboard">
            <a className="mr-6 text-pink-500">Dashboard</a>
          </Link>
        </ul>
      </nav>
      <Component {...pageProps} />
    </div>

  )
}

export default MyApp
