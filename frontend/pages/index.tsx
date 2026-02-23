import { SignInButton, SignUpButton, SignedIn, SignedOut, UserButton } from "@clerk/nextjs";
import Link from "next/link";
import Head from "next/head";

export default function Home() {
  return (
    <>
      <Head>
        <title>Advisor AI - Autonomous Portfolio Intelligence</title>
      </Head>
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-gray-50">
      {/* Navigation */}
      <nav className="px-8 py-6 bg-white shadow-sm">
        <div className="max-w-7xl mx-auto flex justify-between items-center">
          <div className="text-2xl font-bold text-dark">
            Advisor<span className="text-primary">AI</span>
          </div>
          <div className="flex gap-4">
            <SignedOut>
              <SignInButton mode="modal">
                <button className="px-6 py-2 text-primary border border-primary rounded-lg hover:bg-primary hover:text-white transition-colors">
                  Login
                </button>
              </SignInButton>
              <SignUpButton mode="modal">
                <button className="px-6 py-2 bg-primary text-white rounded-lg hover:bg-blue-600 transition-colors">
                  Join Now
                </button>
              </SignUpButton>
            </SignedOut>
            <SignedIn>
              <div className="flex items-center gap-4">
                <Link href="/dashboard">
                  <button className="px-6 py-2 bg-ai-accent text-white rounded-lg hover:bg-purple-700 transition-colors">
                    Access Console
                  </button>
                </Link>
                <UserButton afterSignOutUrl="/" />
              </div>
            </SignedIn>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <section className="px-8 py-20">
        <div className="max-w-7xl mx-auto text-center">
          <h1 className="text-5xl font-bold text-dark mb-6">
          Turning your assets into autonomous intelligence
          </h1>
          <p className="text-xl text-gray-600 mb-8 max-w-3xl mx-auto">
            AI agents to scrutinize your holdings, 
            stress-test your retirement, and unlock hidden growth opportunities.
          </p>
          <div className="flex gap-6 justify-center">
            <SignedOut>
              <SignUpButton mode="modal">
                <button className="px-8 py-4 bg-ai-accent text-white text-lg rounded-lg hover:bg-purple-700 transition-colors shadow-lg">
                  Deploy AI Agent
                </button>
              </SignUpButton>
            </SignedOut>
            <SignedIn>
              <Link href="/dashboard">
                <button className="px-8 py-4 bg-ai-accent text-white text-lg rounded-lg hover:bg-purple-700 transition-colors shadow-lg">
                  Resume Session
                </button>
              </Link>
            </SignedIn>
            <button className="px-8 py-4 border-2 border-primary text-primary text-lg rounded-lg hover:bg-primary hover:text-white transition-colors">
              See How It Works
            </button>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="px-8 py-20 bg-white">
        <div className="max-w-7xl mx-auto">
          <h2 className="text-3xl font-bold text-center text-dark mb-12">
            Your Multi-Agent
          </h2>
          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
            <div className="text-center p-6 rounded-xl hover:shadow-lg transition-shadow">
              <div className="text-4xl mb-4">🧠</div>
              <h3 className="text-xl font-semibold text-ai-accent mb-2">Lead Strategist</h3>
              <p className="text-gray-600">The "brain" that delegates complex tasks across the agent network</p>
            </div>
            <div className="text-center p-6 rounded-xl hover:shadow-lg transition-shadow">
              <div className="text-4xl mb-4">🕵️‍♂️</div>
              <h3 className="text-xl font-semibold text-primary mb-2">Risk Auditor</h3>
              <p className="text-gray-600">Scans for exposure gaps and suggests defensive rebalancing</p>
            </div>
            <div className="text-center p-6 rounded-xl hover:shadow-lg transition-shadow">
              <div className="text-4xl mb-4">🎨</div>
              <h3 className="text-xl font-semibold text-success mb-2">Data Visualizer</h3>
              <p className="text-gray-600">Turns raw market data into high-fidelity, actionable insights</p>
            </div>
            <div className="text-center p-6 rounded-xl hover:shadow-lg transition-shadow">
              <div className="text-4xl mb-4">⏳</div>
              <h3 className="text-xl font-semibold text-accent mb-2">Horizon Projection</h3>
              <p className="text-gray-600">Calculates long-term wealth outcomes using predictive modeling</p>
            </div>
          </div>
        </div>
      </section>

      {/* Benefits Section */}
      <section className="px-8 py-20 bg-gradient-to-r from-primary/10 to-ai-accent/10">
        <div className="max-w-7xl mx-auto">
          <h2 className="text-3xl font-bold text-center text-dark mb-12">
            Next-Gen Tech Infrastructure
          </h2>
          <div className="grid md:grid-cols-3 gap-8">
            <div className="bg-white p-8 rounded-xl shadow-md">
              <div className="text-accent text-2xl mb-4">🚀</div>
              <h3 className="text-xl font-semibold mb-3">Parallel Processing</h3>
              <p className="text-gray-600">Our agents work simultaneously to deliver deep insights in seconds, not hours.</p>
            </div>
            <div className="bg-white p-8 rounded-xl shadow-md">
              <div className="text-accent text-2xl mb-4">🛡️</div>
              <h3 className="text-xl font-semibold mb-3">Encrypted Privacy</h3>
              <p className="text-gray-600">Hardened data silos ensure your financial footprint remains yours alone.</p>
            </div>
            <div className="bg-white p-8 rounded-xl shadow-md">
              <div className="text-accent text-2xl mb-4">📝</div>
              <h3 className="text-xl font-semibold mb-3">AI Intelligence Briefs</h3>
              <p className="text-gray-600">Get plain-English summaries of complex market movements and risks.</p>
            </div>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="px-8 py-20 bg-dark text-white">
        <div className="max-w-4xl mx-auto text-center">
          <h2 className="text-3xl font-bold mb-6">
            Ready to Upgrade Your Strategy?
          </h2>
          <p className="text-xl mb-8 opacity-90">
            Harness the same technology used by top-tier quant funds.
          </p>
          <SignUpButton mode="modal">
            <button className="px-8 py-4 bg-accent text-dark font-semibold text-lg rounded-lg hover:bg-yellow-500 transition-colors shadow-lg">
              Start Free Trial
            </button>
          </SignUpButton>
        </div>
      </section>

      {/* Footer */}
      <footer className="px-8 py-6 bg-gray-900 text-gray-400 text-center text-sm">
        <p>©Advisor AI. Engineering the future of finance.</p>
        <p className="mt-2 italic">
          Disclaimer: This is an AI-driven tool. All projections are simulations. Consult a human professional for definitive legal or tax advice.
        </p>
      </footer>
    </div>
    </>
  );
}