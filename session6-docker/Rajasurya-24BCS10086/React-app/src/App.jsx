import { useState } from 'react'

export default function App() {
  const [count, setCount] = useState(0)

  return (
    <div className="app">
      <h1>Hello World from React!</h1>
      <p>Built with Vite and served by Nginx inside a Docker container.</p>
      <button onClick={() => setCount(count + 1)}>
        clicked {count} times
      </button>
      <p className="small">DevOps homework - React-app</p>
    </div>
  )
}
