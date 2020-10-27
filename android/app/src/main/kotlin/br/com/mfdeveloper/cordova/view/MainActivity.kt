package br.com.mfdeveloper.cordova.view

import android.os.Bundle
import android.view.ViewGroup
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import br.com.mfdeveloper.cordova.databinding.ActivityMainBinding
import br.com.mfdeveloper.cordova.viewmodel.NativeViewModel

/**
 * Activity that uses **ViewBinding** to connect this screen
 * with ViewModel events
 */
class MainActivity : AppCompatActivity() {

    /**
     * {@link viewModels} from androidx.fragment:fragment-ktx:1.2.5
     */
    private val viewModel: NativeViewModel by viewModels()

    /**
     * Generated class from activity_main.xml after add
     *  buildFeatures {
     *    viewBinding = true
     *  }
     *  tyo your app/build.gradle
     *
     *  @see <a href="https://developer.android.com/topic/libraries/view-binding#activities">Use view binding in activities</a>
     */
    private lateinit var binding: ActivityMainBinding
    private lateinit var view: ViewGroup

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        binding = ActivityMainBinding.inflate(layoutInflater)
        binding.openBtn.setOnClickListener { viewModel.open(this) }

        view = binding.root
        setContentView(view)
    }
}