

import './App.css'
import env from "react-dotenv";
function App() {

  return (
    <>
      1) <div>
        <pre>{JSON.stringify(import.meta.env, null, 4)}</pre>
     </div>

     2) <div>
      <pre>{JSON.stringify(env, null, 4)}</pre>
     </div>
    </>
  )
}

export default App
