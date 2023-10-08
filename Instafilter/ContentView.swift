//
//  ContentView.swift
//  Instafilter
//
//  Created by Aaron Brown on 10/8/23.
//
import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

struct ContentView: View {
    @State private var image: Image?
    @State private var filterIntensity: Double = 0.3
    
    @State private var showingImagePickter: Bool = false
    @State private var inputImage: UIImage?
    @State private var processImage: UIImage?
    
    @State private var showingConfirmationSheet: Bool = false
    
    //Creating a new filter into @State
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    //Create a new CIContext
    let context = CIContext()
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    Circle()
                        .fill(.secondary)
                        .frame(width: 300, height: 300)
                    Text("Tap to select a picture")
                        .foregroundStyle(.white)
                        .font(.headline)
                    
                    image?
                        .resizable()
                        .frame(width: 300, height: 300)
                        .scaledToFill()
                        .clipShape(Circle())
                }
                .padding(.bottom,50)
                .onTapGesture {
                    showingImagePickter.toggle()
                }
                HStack {
                    Text("Intensity")
                    Slider(value: $filterIntensity)
                        .onChange(of: filterIntensity, initial: true) { _,_ in applyProcessing() }
                }
                .padding(.vertical)
                HStack {
                    Button("Change Filter", action: {showingConfirmationSheet.toggle()})
                   
                    Spacer()
                    
                    Button("Save", action: save)
                }
            }
            .padding()
            .navigationTitle("Instafilter")
            .onChange(of: inputImage, initial: true) { _,_ in loadImage() }
            .sheet(isPresented: $showingImagePickter) {
                ImagePicker(image: $inputImage)
            }
            .confirmationDialog("Select a filter", isPresented: $showingConfirmationSheet) {
                
                Button("Crystallize") { setFilter(.crystallize())}
                Button("Edges") { setFilter(.edges())}
                Button("Gaussian Blur") { setFilter(.gaussianBlur())}
                Button("Pixellate") { setFilter(.pixellate())}
                Button("Sepia Tone") { setFilter(.sepiaTone())}
                Button("Unsharp Mask") { setFilter(.unsharpMask())}
                Button("Vignette") { setFilter(.vignette())}
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Select a filter")
            }
        }
    }
    
    func loadImage () {
        guard let inputImage = inputImage else { return }
        // Assigns the upload image straight away to the @State image for display
        // image = Image(uiImage: inputImage)
        
        // Converting the loaded image in to a CIImage
        let beginImage = CIImage(image: inputImage)
        // Makeing the image accessable to the current filter
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    func save() {
        guard let processImage = processImage else { return }
        let imageSavor = ImageSaver()
        imageSavor.writeToSavePhotoAlbum(image: processImage)
        
        imageSavor.successHandler = {
            print("Saved")
        }
        
        imageSavor.errorHandler = { error in
            print(error.localizedDescription)
        }
    }
    
    func applyProcessing() {
        // Assigning @State to the CIFilter.sepiaTone() intensity
        // currentFilter.intensity = Float(filterIntensity)
        
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        }
        
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(filterIntensity * 200, forKey: kCIInputRadiusKey)
        }
        
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(filterIntensity * 10, forKey: kCIInputScaleKey)
        }
        
        // If there is an currentFilter.outputImage has a result assign it to outputImage else return
        guard let outputImage = currentFilter.outputImage else { return }
        // If a CGImage can be create from the output image assign it to cgimg
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            //Create a UIImage from the CGImage
            let uiImage = UIImage(cgImage: cgimg)
            //assign the State image with the converted UIImage
            image = Image(uiImage: uiImage)
            processImage = uiImage
        }
    }
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
    }
}

#Preview {
    ContentView()
}
