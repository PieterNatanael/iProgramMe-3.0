//
//  AddNotificationView.swift
//  iProgramMe
//
//  Created by Jonathan Lee on 29/12/23.
//

import SwiftUI
import PhotosUI

struct AddNotificationView: View {
    // Photo picker state
    @Binding var selectedImage: PhotosPickerItem?
    @Binding var selectedImageData: Data?
    
    // Form value
    @Binding var newText: String
    @Binding var selectedTime: Date
    
    // Show add notification sheet
    @Binding var showAddNotificationSheet: Bool
    var addNotification: () -> Void
    
    var body: some View {
        NavigationStack {
            List {
                Section(content: {}, header: {
                    HStack {
                        Spacer()
                        
                        VStack(spacing: 12) {
                            if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 150, height: 150)
                                    .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                            } else {
                                Image(systemName: "photo.circle.fill")
                                    .resizable()
                                    .foregroundStyle(.white, Gradient(colors: [Color(uiColor: .lightGray), .gray]))
                                    .scaledToFit()
                                    .frame(width: 150, height: 150)
                            }
                            
                            PhotosPicker(
                                selection: $selectedImage,
                                matching: .images,
                                photoLibrary: .shared()
                            ) {
                                Text("Add photo")
                            }
                            .textCase(nil)
                            .buttonStyle(.bordered)
                            .clipShape(Capsule())
                            .onChange(of: selectedImage) { newValue in
                                Task {
                                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                        selectedImageData = data
                                    }
                                }
                            }
                        }
                        Spacer()
                    }
                })
                Section(content: {
                    TextField("Enter message", text: $newText)
                    DatePicker("Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                }, footer: {
                    Text("You can add new notification between message only, photo only, or both.")
                })
            }
            .listStyle(.insetGrouped)
            .toolbar(content: {
                ToolbarItemGroup(placement:.confirmationAction) {
                    Button {
                        // Add the notification
                        addNotification()
                        
                        // Close the notification sheet
                        showAddNotificationSheet.toggle()
                    } label: {
                        Text("Done")
                    }
                    .disabled(
                        newText.isEmpty && selectedImage == nil
                    )
                }
                
                ToolbarItemGroup(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        showAddNotificationSheet.toggle()
                    } label: {
                        Text("Cancel")
                    }
                }
            })
            .navigationTitle("New Notification")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.large])
    }
}
